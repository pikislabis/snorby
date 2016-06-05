require 'test_helper'

class SeveritiesControllerTest < ActionController::TestCase
  setup do
    @high = severities(:high)
    @very_low = severities(:very_low)
    @admin = users(:admin)
    sign_in @admin
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:severities)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create severity' do
    assert_difference('Severity.count') do
      post :create, severity: { name: 'new', sig_id: 5, bg_color: '#dddddd',
                                text_color: '#ffffff' }
    end

    assert_redirected_to severities_path
  end

  test 'should get edit' do
    get :edit, id: @high.id
    assert_response :success
  end

  test 'should update severity' do
    put :update, id: @high.to_param, severity: @high.attributes
    assert_redirected_to severities_path
  end

  test 'should destroy severity' do
    assert_difference('Severity.count', -1) do
      delete :destroy, id: @very_low.to_param
    end

    assert_redirected_to severities_path
  end
end
