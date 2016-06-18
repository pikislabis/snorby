require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  context 'normal user' do
    setup do
      @user = users(:user)
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    should 'log in' do
      post :create, user: { email: @user.email, password: 'snorby' }
      assert_redirected_to root_path
    end

    should 'log in (json format)' do
      post :create, user: { email: @user.email, password: 'snorby' },
                    format: :json
      result = JSON.parse(response.body)
      assert(result['success'])
      assert_equal(result['user']['email'], @user.email)
      assert_equal(result['redirect'], root_path)
    end

    should 'fail log in' do
      post :create, user: { email: @user.email, password: 'wrong_password' },
                    format: :json
      result = JSON.parse(response.body)
      assert_not(result['success'])
    end

    should 'log out' do
      sign_in @user
      delete :destroy
      assert_redirected_to root_path
    end
  end
end
