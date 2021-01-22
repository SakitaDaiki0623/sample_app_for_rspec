require 'rails_helper'

RSpec.describe 'Tasks', type: :system do
  include LoginSupport

  let(:user) { create(:user, email: 'user@example.com') }
  let(:other_user) { create(:user, email: 'other_user@example.com') }
  let(:user_task) { create(:task, title: 'user_task', user: user) }

  describe 'before login' do
    describe 'check page transtion' do
      context 'when accesses to new task page' do
        it 'fails to access' do
          visit new_task_path
          expect(page).to have_content 'Login required'
          expect(current_path).to eq login_path
        end
      end
      context 'when accesses to edit task page' do
        it 'fails to access' do
          visit edit_task_path(user_task)
          expect(page).to have_content 'Login required'
          expect(current_path).to eq login_path
        end
      end
      context 'when accesses to show task page' do
        it 'successfully access' do
          visit task_path(user_task)
          expect(page).to have_content user_task.title
          expect(current_path).to eq task_path(user_task)
        end
      end
      context 'when accesses to index task page' do
        it 'tasks created by users are all desplayed' do
          task_list = create_list(:task, 3)
          visit tasks_path
          expect(page).to have_content task_list[0].title
          expect(page).to have_content task_list[1].title
          expect(page).to have_content task_list[2].title
          expect(current_path).to eq tasks_path
        end
      end
    end
  end

  describe 'after user login' do
    before { sign_in_as(user) }
    describe 'task index function' do
      context 'when user accesses to root_path' do
        let!(:user_task) { create(:task, user: user) }
        before { visit root_path }
        it 'user_task and links are displayed' do
          expect(page).to have_content user_task.title
          expect(page).to have_link 'Show', href: task_path(user_task)
          expect(page).to have_link 'Edit', href: edit_task_path(user_task)
          expect(page).to have_link 'Destroy', href: task_path(user_task)
        end
      end
    end
  
    describe 'task create function' do
      describe 'user creates a new task' do
        before { visit new_task_path }
        context 'when input values in the form are all valid' do
          before do
            fill_in 'Title', with: 'example_title'
            fill_in 'Content', with: 'example_content'
            select :todo, from: 'Status'
            fill_in 'Deadline', with: DateTime.new(2021, 1, 22, 12, 30)
            click_button 'Create Task'
          end
          it 'is successfully created' do
            expect(page).to have_content 'Task was successfully created.'
            expect(page).to have_content 'Title: example_title'
            expect(page).to have_content 'Content: example_content'
            expect(page).to have_content 'Status: todo'
            expect(page).to have_content 'Deadline: 2021/1/22 12:30'
            expect(current_path).to eq '/tasks/1'
          end
        end
        context 'when title is nil' do
          before do
            fill_in 'Title', with: nil
            fill_in 'Content', with: 'example_content'
            click_button 'Create Task'
          end
          it 'fails to be created' do
            expect(page).to have_content '1 error prohibited this task from being saved:'
            expect(page).to have_content "Title can't be blank"
            expect(current_path).to eq tasks_path
          end
        end
        context 'when already registered title is used' do
          before do
            other_task = create(:task)
            fill_in 'Title', with: other_task.title
            fill_in 'Content', with: 'example_content'
            click_button 'Create Task'
          end
          it 'fails to be created' do
            expect(page).to have_content '1 error prohibited this task from being saved'
            expect(page).to have_content 'Title has already been taken'
            expect(current_path).to eq tasks_path
          end
        end
      end
    end
  
    describe 'task show function' do
      before { visit task_path(user_task) }
      it 'attributes of user_task are all displayed' do
        expect(page).to have_content "Title: #{user_task.title}"
        expect(page).to have_content "Content: #{user_task.content}"
        expect(page).to have_content "Status: #{user_task.status}"
        expect(page).to have_content "Deadline: #{user_task.deadline.strftime('%Y/%-m/%-d %-H:%-M')}"
      end
    end
  
    describe 'task update function' do
      before { visit edit_task_path(user_task) }
      context 'when user edits with valid title and status' do
        before do
          fill_in 'Title', with: 'updated_title'
          fill_in 'Content', with: 'updated_content'
          select :doing, from: 'Status'
          click_button 'Update Task'
        end
        it 'is successfully updated' do
          expect(page).to have_content 'Task was successfully updated.'
          expect(page).to have_content 'Title: updated_title'
          expect(page).to have_content 'Content: updated_content'
          expect(page).to have_content 'Status: doing'
          expect(current_path).to eq task_path(user_task)
        end
      end
      context 'when user edits title with nil' do
        before do
          fill_in 'Title', with: nil
          click_button 'Update Task'
        end
        it 'title of user_task is displayed' do
          expect(page).to have_content '1 error prohibited this task from being saved'
          expect(page).to have_content "Title can't be blank"
          expect(current_path).to eq task_path(user_task)
        end
      end
      context 'when user edits title with already registered title' do
        before do
          other_task = create(:task)
          fill_in 'Title', with: other_task.title
          click_button 'Update Task'
        end
        it 'title of user_task is displayed' do
          expect(page).to have_content '1 error prohibited this task from being saved'
          expect(page).to have_content 'Title has already been taken'
          expect(current_path).to eq task_path(user_task)
        end
      end
    end
    
    describe 'task destroy function' do
      context "when user click 'Destroy' link" do
        let!(:user_task) { create(:task, user: user) }
        before do
          visit root_path
          click_link 'Destroy'
          # accept confirm dialogue
          page.driver.browser.switch_to.alert.accept
        end
        it 'user_task is destroyed' do
          expect(page).to have_content 'Task was successfully destroyed.'
          expect(page).not_to have_content user_task.title
          expect(current_path).to eq tasks_path
        end
      end
    end
  end

  describe 'after other user login' do
    let!(:user_task) { create(:task, user: user) }
    before { sign_in_as(other_user) }
    context 'when other_user does not have own task' do
      it 'only show link is displayed' do
        expect(page).to have_link 'Show', href: task_path(user_task)
        expect(page).not_to have_link 'Edit', href: edit_task_path(user_task)
        expect(page).not_to have_link 'Destroy', href: task_path(user_task)
      end
    end
    context 'when other_user accesses to user_task show page' do
      before { visit task_path(user_task) }
      it 'attributes of user_task are all displayed' do
        expect(page).to have_content "Title: #{user_task.title}"
        expect(page).to have_content "Content: #{user_task.content}"
        expect(page).to have_content "Status: #{user_task.status}"
        expect(page).to have_content "Deadline: #{user_task.deadline.strftime('%Y/%-m/%-d %-H:%-M')}"
      end
    end
    context 'when other_user accesses to user_task edit page' do
      before { visit edit_task_path(user_task) }
      it 'title of user_task is displayed' do
        expect(page).to have_content 'Forbidden access.'
        expect(current_path).to eq root_path
      end
    end
  end
end