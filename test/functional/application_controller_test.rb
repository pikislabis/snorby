require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  tests PageController

  context 'non login user' do
    setup do
      get :dashboard
    end

    should redirect_to '/users/login'
  end

  context 'normal user' do
    setup do
      @user = users(:user)
      sign_in @user
    end

    should 'be logout if is disabled' do
      @user.update(enabled: false)
      get :dashboard
      assert_redirected_to '/users/login'
    end
  end
end
