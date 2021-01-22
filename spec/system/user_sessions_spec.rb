require 'rails_helper'

RSpec.describe 'UserSessions', type: :system do

  let(:user) { create(:user) }

  describe 'before login' do
    before { visit login_path }
    context 'when input values in the form are all valid' do
      before do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: 'password'
        click_button 'Login'
      end
      it 'login successfully' do
        expect(page).to have_content 'Login successful'
        expect(current_path).to eq root_path
      end
    end
    context 'when no value is entered in the form' do
      before do
        fill_in 'Email', with: ''
        fill_in 'Password', with: 'password'
        click_button 'Login'
      end
      it 'falis to login' do
        expect(page).to have_content 'Login failed'
        expect(current_path).to eq login_path
      end
    end
  end
  
  describe 'after user login' do
    before { sign_in_as(user) }
    context 'when an user clicks the link to log out' do
      before { click_link 'Logout' }
      it 'logged out successfully' do
        expect(page).to have_content 'Logged out'
        expect(current_path).to eq root_path
      end
    end
  end
end