require 'test_helper'

class PasswordsControllerTest < ActionController::TestCase
  context 'non login user' do
    setup do
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    should 'get forget password form' do
      get :new
      assert_template layout: 'login'
    end
  end
end
