require 'test_helper'

class PageControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    sign_in @admin
  end

  test 'access dashboard' do
    get :dashboard
    assert_response :success
  end

  test 'access search' do
    get :search
    assert_response :success
  end

  test 'get search_json' do
    get :search_json
    assert_response :success
  end

  test 'get cache status' do
    get :cache_status
    assert_response :success
  end
end
