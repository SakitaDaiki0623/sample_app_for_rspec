require 'rails_helper'

RSpec.describe 'Users', type: :system do

  let(:user) { create(:user, email: 'user@example.com') }
  let(:other_user) { create(:user, email: 'other_user@example.com') }

  describe 'before login' do
    describe 'sign up' do
      before { visit sign_up_path }
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
          fill_in 'Email', with: nil
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'SignUp'
        end
        it 'fails to create a new user' do
          expect(page).to have_content '1 error prohibited this user from being saved'
          expect(page).to have_content "Email can't be blank"
          expect(current_path).to eq users_path
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
          expect(page).to have_content '1 error prohibited this user from being saved'
          expect(page).to have_content 'Email has already been taken'
          expect(current_path).to eq users_path
          expect(page).to have_field 'Email', with: user.email
        end
      end
    end
    
    describe 'Mypage' do
      context 'when accesses to Mypage' do
        before { visit user_path(user) }
        it 'fails to access' do
          expect(page).to have_content 'Login required'
          expect(current_path).to eq login_path
        end
      end
    end

    describe 'new task page' do
      context 'when accesses to new task page' do
        before { visit new_task_path }
        it 'fails to access' do
          expect(page).to have_content 'Login required'
          expect(current_path).to eq login_path
        end
      end
    end

    describe 'edit task page' do
      context 'when accesses to edit task page' do
        before do
          task = create(:task, title: 'test_title', status: :doing, user: user)
          visit edit_task_path(task)
        end
        it 'fails to access' do
          expect(page).to have_content 'Login required'
          expect(current_path).to eq login_path
        end
      end
    end
  end
  
  describe 'after user login' do
    before { sign_in_as(user) }
    describe 'edit user' do
      before { visit edit_user_path(user) }
      context 'when input values in the form are all valid' do
        before do
          fill_in 'Email', with: 'updated@example.com'
          fill_in 'Password', with: 'updated_password'
          fill_in 'Password confirmation', with: 'updated_password'
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
          fill_in 'Password', with: 'updated_password'
          fill_in 'Password confirmation', with: 'updated_password'
          click_button 'Update'
        end
        it 'fails to be editted' do
          expect(page).to have_content '1 error prohibited this user from being saved'
          expect(page).to have_content "Email can't be blank"
          expect(current_path).to eq user_path(user)
        end
      end

      context 'when already registered email is used' do
        before do
          fill_in 'Email', with: other_user.email
          fill_in 'Password', with: 'updated_password'
          fill_in 'Password confirmation', with: 'updated_password'
          click_button 'Update'
        end
        it 'fails to be editted' do
          expect(page).to have_content '1 error prohibited this user from being saved'
          expect(page).to have_content 'Email has already been taken'
          expect(current_path).to eq user_path(user)
        end
      end

      context 'when user accesses to page to edit other_user' do
        before { visit edit_user_path(other_user) }
        it 'fails to access' do
          expect(page).to have_content 'Forbidden access.'
          expect(current_path).to eq user_path(user)
        end
      end
    end

    describe 'Mypage' do
      context 'when user creates a new task' do
        before do
          create(:task, title: 'test_title', status: :doing, user: user)
          visit user_path(user)
        end
        it 'the new task is displayed' do
          expect(page).to have_content('You have 1 task.')
          expect(page).to have_content('test_title')
          expect(page).to have_content('doing')
          expect(page).to have_link('Show')
          expect(page).to have_link('Edit')
          expect(page).to have_link('Destroy')
        end
      end
    end
  end
end