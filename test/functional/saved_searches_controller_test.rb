require 'test_helper'

class SavedSearchesControllerTest < ActionController::TestCase
  context 'normal user' do
    setup do
      @user = users(:user)
      @search_one = saved_searches(:one)
      @search_two = saved_searches(:two)
      @search_three = saved_searches(:three)
      sign_in @user
    end

    should 'get index' do
      get :index
      assert_response :success
    end

    should 'get new form' do
      get :new
      assert_response :success
    end

    should 'create a public search' do
      post :create, search: { title: 'New Save', public: true,
                              search: { match_all: true,
                                        items: {
                                          '0' => { column: 'source_ip',
                                                   operator: 'is',
                                                   value: '192.30.252.129',
                                                   enabled: true }
                                        } } }
      assert_response :success
    end

    should 'fail creating a wrong search' do
      post :create, search: { title: 'New Save', public: true }
      result = JSON.parse(response.body)
      assert(result['error'])
    end

    should 'get a public saved search' do
      get :show, id: @search_one.id
      result = JSON.parse(response.body)
      assert(result['search'])
    end

    should 'not get a private saved search' do
      get :show, id: @search_two.id
      result = JSON.parse(response.body)
      assert_empty(result)
    end

    should 'get an own search' do
      get :show, id: @search_three.id
      result = JSON.parse(response.body)
      assert(result['search'])
    end

    should 'not get an inexisted saved search' do
      get :show, id: Random.new.rand(1000)
      result = JSON.parse(response.body)
      assert_empty(result)
    end

    should 'view own search' do
      get :view, id: @search_three.id
      assert_response :success
    end

    should "not view other's saved search" do
      get :view, id: @search_one.id
      assert_redirected_to saved_searches_path
    end

    should 'not view an inexisted saved search' do
      get :view, id: Random.new.rand(1000)
      assert_redirected_to saved_searches_path
    end

    should 'update a saved search' do
      search = @search_three.search.merge('match_all' => 'false')
      put :update, id: @search_three.id, search: search
      result = JSON.parse(response.body)
      assert_equal(result['search']['match_all'], 'false')
    end

    should "modify saved search's title" do
      new_title = 'New title'
      post :title, id: @search_three, title: new_title
      assert_equal(response.body, new_title)
    end

    should 'not update invalid title' do
      post :title, id: @search_three, title: ''
      result = JSON.parse(response.body)
      assert(result['title'])
    end

    should 'destroy own saved search' do
      delete :destroy, id: @search_three
      assert_redirected_to saved_searches_path
      assert flash[:success]
    end

    should "not destroy other's saved search" do
      delete :destroy, id: @search_one.id
      assert_redirected_to saved_searches_path
      assert(flash.empty?)
    end
  end
end
