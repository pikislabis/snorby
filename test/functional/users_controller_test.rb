require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  context 'admin user' do
    setup do
      @admin = users(:admin)
      @user = users(:user)
      sign_in @admin
    end

    should 'get list' do
      get :index
      assert_response :success
    end

    should 'get new' do
      get :new
      assert_response :success
    end

    should 'create user' do
      post :add, user: { name: 'New user', email: 'new@example.com',
                         password: 'new_password',
                         password_confirmation: 'new_password',
                         per_page_count: 25, admin: false }
      assert_redirected_to users_path
    end

    should 'disable an user' do
      post :toggle_settings, user_id: @user.id, user: { enabled: false }
      result = JSON.parse(response.body)
      assert result.key?('success')
    end

    should 'remove an user' do
      delete :remove, id: @user.id
      assert_redirected_to users_path
    end
  end
end
