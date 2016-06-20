require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  context 'admin user' do
    setup do
      @admin = users(:admin)
      @job_one = delayed_jobs(:one)
      @job_two = delayed_jobs(:two)
      sign_in @admin
    end

    should 'get index' do
      get :index
      assert_response :success
    end

    should 'get last_error' do
      get :last_error, id: @job_two.id
      assert_response :success
    end

    should 'get handler' do
      get :handler, id: @job_one.id
      assert_response :success
    end

    should 'get job' do
      get :show, id: @job_one.id
      assert_response :success
    end

    should 'destroy job' do
      assert_difference('DelayedJob.count', -1) do
        delete :destroy, id: @job_one.id
      end
      assert_redirected_to jobs_path
    end
  end
end
