require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  context 'admin user' do
    setup do
      @admin = users(:admin)
      sign_in @admin
    end

    should 'get index' do
      get :index
      assert_response :success
    end

    should 'update settings' do
      post :create, settings: { company: 'New Company' }
      assert_redirected_to settings_path
    end

    should 'start worker' do
      Snorby::Worker.stubs(:start)
      get :start_worker
      assert_redirected_to jobs_path
    end

    should 'start sensor cache job' do
      get :start_sensor_cache
      assert_redirected_to jobs_path
    end

    should 'start daily cache job' do
      get :start_daily_cache
      assert_redirected_to jobs_path
    end

    should 'start geoip update job' do
      get :start_geoip_update
      assert_redirected_to jobs_path
    end

    should 'restart worker' do
      Snorby::Worker.stubs(:restart)
      get :restart_worker
      assert_redirected_to jobs_path
    end
  end
end
