require 'test_helper'

class ClassificationsControllerTest < ActionController::TestCase
  context 'admin user' do
    setup do
      @admin = users(:admin)
      @classification = classifications(:one)
      sign_in @admin
    end

    should 'get classifications' do
      get :index
      assert_response :success
    end

    should 'get classification' do
      get :show, id: @classification.id
      assert_response :success
    end

    should 'get new' do
      get :new
      assert_response :success
    end

    should 'get edit' do
      get :edit, id: @classification.id
      assert_response :success
    end

    should 'create classification' do
      post :create, classification: { name: 'New Classification',
                                      description: 'Classification created' }
      assert_redirected_to classifications_path
    end

    should 'update classification' do
      put :update, id: @classification.id,
                   classification: { name: 'Update classification',
                                     description: 'Classification updated' }
      assert_redirected_to classifications_path
    end

    should 'destroy classification' do
      delete :destroy, id: @classification.id
      assert_redirected_to classifications_path
    end
  end

  context 'non admin user' do
    setup do
      @user = users(:user)
      sign_in @user
    end

    should 'should\'t access classification' do
      get :index
      assert_response 302
    end
  end
end
