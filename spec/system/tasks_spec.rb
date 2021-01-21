require 'rails_helper'

RSpec.describe 'Tasks', type: :system do
  include LoginSupport

  let(:user) { create(:user, email: 'user@example.com') }
  let(:other_user) { create(:user, email: 'other_user@example.com') }
  let!(:user_task) { create(:task, title: 'user_task', user: user) }

  describe 'task index function' do
    context 'when user login' do
      before do
        sign_in_as(user)
      end
      it 'title of user_task is displayed' do
        expect(page).to have_content user_task.title
      end
      it 'show, edit, and destroy links of user_task are displayed' do
        expect(page).to have_link 'Show', href: task_path(user_task)
        expect(page).to have_link 'Edit', href: edit_task_path(user_task)
        expect(page).to have_link 'Destroy', href: task_path(user_task)
      end
    end

    context 'when other_user login' do
      before do
        sign_in_as(other_user)
      end
      it 'title of user_task is displayed' do
        expect(page).to have_content user_task.title
      end
      it 'only show link is displayed' do
        expect(page).to have_link 'Show', href: task_path(user_task)
        expect(page).not_to have_link 'Edit', href: edit_task_path(user_task)
        expect(page).not_to have_link 'Destroy', href: task_path(user_task)
      end
    end
  end

  describe 'task create function' do
    describe 'user creates a new task' do
      before do
        sign_in_as(user)
        visit new_task_path
      end
      context 'when input values in the form are all valid' do
        before do
          fill_in 'Title', with: 'example_title'
          fill_in 'Content', with: 'example_content'
          select :todo, from: 'Status'
          fill_in 'Deadline', with: 1.week.from_now
          click_button 'Create Task'
        end
        it 'is successfully created' do
          expect(page).to have_content 'Task was successfully created.'
          expect(page).to have_content 'example_title'
        end
      end
      context 'when title is nil' do
        before do
          fill_in 'Content', with: 'example_content'
          select :todo, from: 'Status'
          fill_in 'Deadline', with: 1.week.from_now
          click_button 'Create Task'
        end
        it 'fails to be created' do
          expect(page).to have_content "Title can't be blank"
        end
      end
      context 'when content and deadline is nil' do
        before do
          fill_in 'Title', with: 'example_title'
          select :todo, from: 'Status'
          click_button 'Create Task'
        end
        it 'is successfully created' do
          expect(page).to have_content 'Task was successfully created.'
          expect(page).to have_content 'example_title'
        end
      end
    end
  end

  describe 'task show function' do
    context 'when user login and access to task show page' do
      before do
        sign_in_as(user)
        visit task_path(user_task)
      end
      it 'title of user_task is displayed' do
        expect(page).to have_content user_task.title
      end
    end
    context 'when other_user login and access to task show page' do
      before do
        sign_in_as(other_user)
        visit task_path(user_task)
      end
      it 'title of user_task is displayed' do
        expect(page).to have_content user_task.title
      end
    end
  end

  describe 'task update function' do
    describe 'user edit user task' do
      before do
        sign_in_as(user)
        visit edit_task_path(user_task)
      end
      context 'when user edits title with valid words' do
        before do
          fill_in 'Title', with: 'valid_words'
          click_button 'Update Task'
        end
        it 'title of user_task is displayed' do
          expect(page).to have_content 'Task was successfully updated.'
          expect(page).to have_content 'valid_words'
          expect(current_path).to eq task_path(user_task)
        end
      end
      context 'when user edits title with nil' do
        before do
          fill_in 'Title', with: nil
          click_button 'Update Task'
        end
        it 'title of user_task is displayed' do
          expect(page).to have_content "Title can't be blank"
          expect(page).not_to have_content 'Task was successfully updated.'
        end
      end
    end
    
    context 'when other_user login and access to user_task edit page' do
      before do
        sign_in_as(other_user)
        visit edit_task_path(user_task)
      end
      it 'title of user_task is displayed' do
        expect(page).to have_content 'Forbidden access.'
      end
    end
  end
  
  describe 'task destroy function' do
    context "when user click 'Destroy' link" do
      before do
        sign_in_as(user)
        click_link 'Destroy', href: task_path(user_task)
        # ↓コンファームダイアログのポップアップでタスク削除を承認
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