require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  context 'normal user' do
    setup do
      @user = users(:user)
      sign_in @user
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    should 'update his profile' do
      put :update, user: { name: 'New Name', current_password: 'snorby' }
      assert_redirected_to edit_user_registration_path
      assert(flash[:notice])
    end

    should 'not update his profile with wrong current_password' do
      put :update, user: { name: 'New Name', current_password: 'wrong_password' }
      assert_not_equal(User.find(@user.id).name, 'New Name')
    end
  end
end
