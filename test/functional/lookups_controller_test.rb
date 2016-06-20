require 'test_helper'

class LookupsControllerTest < ActionController::TestCase
  context 'admin user' do
    setup do
      @admin = users(:admin)
      @lookup = lookups(:one)
      sign_in @admin
    end

    should 'get index' do
      get :index
      assert_response :success
    end

    should 'get new form' do
      get :new
      assert_response :success
    end

    should 'get edit form' do
      get :edit, id: @lookup.id
      assert_response :success
    end

    should 'create a lookup' do
      assert_difference('Lookup.count', 1) do
        post :create, lookup: { title: 'New Lookup',
                                value: 'http://www.example.com/lookup?address=${ip}' }
      end

      assert_redirected_to lookups_path
    end

    should 'not create a lookup without title' do
      assert_difference('Lookup.count', 0) do
        post :create, lookup: { value: 'http://www.example.com/lookup?address=${ip}' }
      end
    end

    should 'edit a lookup' do
      put :update, id: @lookup.id, lookup: { title: 'Updated title' }
      assert_redirected_to lookups_path
    end

    should 'not edit a lookup without value' do
      put :update, id: @lookup.id, lookup: { value: '' }
      assert_not_equal(Lookup.find(@lookup.id).value, '')
    end

    should 'destroy a lookup' do
      assert_difference('Lookup.count', -1) do
        delete :destroy, id: @lookup.id
      end

      assert_redirected_to lookups_path
    end
  end
end
