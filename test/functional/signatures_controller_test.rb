require 'test_helper'

class SignaturesControllerTest < ActionController::TestCase
  context 'admin user' do
    setup do
      @admin = users(:admin)
      sign_in @admin
    end

    should 'get signatures order by events_count asc' do
      get :index, direction: 'asc', sort: 'events_count'
      assert_response :success
    end

    should 'search' do
      query = 'DNP3 Application-Layer'
      signatures = Signature.where('sig_name like ?', "%#{query}%")
      total = Signature.count

      get :search, q: query
      result = JSON.parse(response.body)
      assert(result['signatures'].length, signatures.count)
      assert(result['total'], total)
    end

    should 'get empty result when search without query' do
      get :search
      result = JSON.parse(response.body)
      assert(result['signatures'].length, 0)
    end
  end

  context 'normal user' do
    setup do
      @user = users(:user)
      sign_in @user
    end

    should 'not access index' do
      get :index
      assert_redirected_to root_path
    end
  end
end
