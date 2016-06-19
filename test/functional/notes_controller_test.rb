require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  context 'normal user' do
    setup do
      @user = users(:user)
      @event = events(:one)
      @note = notes(:one)
      sign_in @user
    end

    should 'get new note' do
      xhr :get, :new, sid: @event.sid, cid: @event.cid, format: :js
      assert_response :success
    end

    should 'create a note' do
      assert_difference('Note.count', 1) do
        post :create, sid: @event.sid, cid: @event.cid, body: 'Text for note',
                      format: :js
      end

      assert_response :success
    end

    should 'not destroy a note' do
      delete :destroy, id: @note.id
      assert_redirected_to root_path
      assert(flash[:notice])
    end
  end

  context 'admin user' do
    setup do
      @admin = users(:admin)
      @note = notes(:one)
      sign_in @admin
    end

    should 'destroy a note' do
      assert_difference('Note.count', -1) do
        delete :destroy, id: @note.id
      end

      assert_response :success
    end
  end
end
