require 'rails_helper'

RSpec.describe 'Users', type: :system do
  include LoginSupport

  let(:user) { create(:user, email: 'user@example.com') }
  let(:other_user) { create(:user, email: 'other_user@example.com') }
  let!(:user_task) { create(:task, title: 'user_task', user: user) }

  describe 'before login' do
    describe 'sign up' do
      before do
        visit sign_up_path
      end
      context 'when input values in the form are all valid' do
        before do
          fill_in 'Email', with: 'sample@example.com'
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'SignUp'
        end
        it 'is successfully created' do
          expect(page).to have_content 'User was successfully created.'
          expect(current_path).to eq login_path
        end
      end
      context 'when email is nil' do
        before do
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'SignUp'
        end
        it 'fails to create a new user' do
          expect(page).to have_content "Email can't be blank"
        end
      end
      context 'when already registered email is used' do
        before do
          fill_in 'Email', with: user.email
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'SignUp'
        end
        it 'fails to create a new user' do
          expect(page).to have_content 'Email has already been taken'
        end
      end
    end
    
    describe 'Mypage' do
      context 'when accesses to Mypage' do
        before do
          visit user_path(user)
        end
        it 'fails to access' do
          expect(page).to have_content 'Login required'
          expect(current_path).to eq login_path
        end
      end
    end

    describe 'new task page' do
      context 'when accesses to new task page' do
        before do
          visit new_task_path
        end
        it 'fails to access' do
          expect(page).to have_content 'Login required'
          expect(current_path).to eq login_path
        end
      end
    end

    describe 'edit task page' do
      context 'when accesses to edit task page' do
        before do
          visit edit_task_path(user_task)
        end
        it 'fails to access' do
          expect(page).to have_content 'Login required'
          expect(current_path).to eq login_path
        end
      end
    end
  end
  
  describe 'after user login' do
    before do
      sign_in_as(user)
    end
    describe 'edit user' do
      before do
        visit edit_user_path(user)
      end
      context 'when input values in the form are all valid' do
        before do
          fill_in 'Email', with: 'sample@example.com'
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'Update'
        end
        it 'is successfully updated' do
          expect(page).to have_content 'User was successfully updated.'
          expect(current_path).to eq user_path(user)
        end
      end
      context 'when email is nil' do
        before do
          fill_in 'Email', with: nil
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'Update'
        end
        it 'fails to be editted' do
          expect(page).to have_content "Email can't be blank"
        end
      end
      context 'when already registered email is used' do
        before do
          fill_in 'Email', with: other_user.email
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'Update'
        end
        it 'fails to be editted' do
          expect(page).to have_content 'Email has already been taken'
        end
      end
    end

    describe 'Mypage' do
      context 'user accesses to Mypage' do
        before do
          visit user_path(user)
        end
        it 'user email, user_task, links of user_task are displayed are all desplayed' do
          expect(page).to have_content user.email
          expect(page).to have_content 'You have 1 task.'
          expect(page).to have_content user_task.title
          expect(page).to have_content user_task.status
          expect(page).to have_link 'Show', href: task_path(user_task)
          expect(page).to have_link 'Edit', href: edit_task_path(user_task)
          expect(page).to have_link 'Destroy', href: task_path(user_task)
        end
      end
    end
  end

  describe 'after other_user login' do
    before do
      sign_in_as(other_user)
    end
    context 'when other_user accesses to edit user page' do
      before do
        visit edit_user_path(user)
      end
      it 'fails to access' do
        expect(page).to have_content 'Forbidden access.'
        expect(current_path).to eq user_path(other_user)
      end
    end
    context "when other_user accesses to user's task edit page" do
      before do
        visit edit_task_path(user_task)
      end
      it 'fails to access' do
        expect(page).to have_content 'Forbidden access.'
        expect(current_path).to eq root_path
      end
    end
  end
end