require 'test_helper'

class PageControllerTest < ActionController::TestCase
  setup do
    @user = users(:admin)
    sign_in @user
  end

  test 'access dashboard' do
    get :dashboard, range: 'custom',
                    start: Time.now - 2.hours, end: Time.now
    assert_response :success
  end

  %w(last_24 today yesterday week last_week month last_month quarter year other).each do |range|
    test "access dashboard with range #{range}" do
      get :dashboard, range: range
      assert_response :success
    end
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

  test 'force cache' do
    get :force_cache
    assert DelayedJob.sensor_cache?
  end

  test 'search for source IP' do
    get :results, match_all: true,
                  search: { '0' => { column: 'source_ip',
                                     operator: 'is',
                                     value: '192.168.1.1',
                                     enabled: true } }
    assert_response :success
  end
end
