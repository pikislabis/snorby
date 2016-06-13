require 'test_helper'

class SensorsControllerTest < ActionController::TestCase
  context 'admin user' do
    setup do
      @admin = users(:admin)
      @sensor = sensors(:one)
      sign_in @admin
    end

    should 'get agents' do
      get :agent_list
      assert_response :success
    end

    should 'get index' do
      get :index
      assert_response :success
    end

    should 'destroy sensor' do
      Snorby::Worker.stubs(:running?).returns(true)
      delete :destroy, id: @sensor.id
      assert_redirected_to sensors_path
    end

    should 'update name' do
      post :update_name, id: @sensor.id, name: 'new_name'
      result = response.body
      assert_equal(result, 'new_name')
    end
  end
end
