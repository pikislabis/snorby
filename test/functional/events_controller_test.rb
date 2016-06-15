require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  context 'normal user' do
    setup do
      @user = users(:user)
      @event = events(:one)
      @event_2 = events(:two)
      @classification = classifications(:one)
      sign_in @user
    end

    should 'get index' do
      get :index
      assert_response :success
    end

    should 'get index json' do
      get :index, format: :json
      assert_response :success
    end

    should 'get sessions' do
      get :sessions
      assert_response :success
    end

    should 'get sessions sort by sig_priority' do
      get :sessions, sort: :sig_priority
      assert_response :success
    end

    should 'get queue' do
      get :queue
      assert_response :success
    end

    should 'request packet capture' do
      start_time = Time.now - 1.hour
      end_time = Time.now
      Setting.stubs(:find).with(:packet_capture_type).returns('openfpc')
      post :request_packet_capture, sid: @event.sid, cid: @event.cid,
                                    start_time: { '(1i)' => start_time.year.to_s,
                                                  '(2i)' => start_time.month.to_s,
                                                  '(3i)' => start_time.day.to_s,
                                                  '(4i)' => start_time.hour.to_s,
                                                  '(5i)' => start_time.min.to_s },
                                    end_time: { '(1i)' => end_time.year.to_s,
                                                '(2i)' => end_time.month.to_s,
                                                '(3i)' => end_time.day.to_s,
                                                '(4i)' => end_time.hour.to_s,
                                                '(5i)' => end_time.min.to_s },
                                    format: :js
      assert_response :success
    end

    should 'get rule' do
      get :rule, sid: @event.sid, cid: @event.cid
      assert_response :success
    end

    %w(html pdf xml csv json).each do |format|
      should "show rule (#{format} format)" do
        get :show, sid: @event.sid, cid: @event.cid, format: format.to_sym
        assert_response :success
      end
    end

    should 'show rule (js format)' do
      xhr :get, :show, sid: @event.sid, cid: @event.cid, format: :js
      assert_response :success
    end

    should 'view rule' do
      get :view, sid: @event.sid, cid: @event.cid
      assert_response :success
    end

    should 'new email' do
      get :create_email, sid: @event.sid, cid: @event.cid
      assert_response :success
    end

    should 'send email' do
      post :email, sid: @event.sid, cid: @event.cid,
                   email: { to: 'user@example.com', subject: 'Subject',
                            body: 'Email body' }, format: :js
      assert_response :success
    end

    should 'new mass action' do
      get :create_mass_action, sid: @event.sid, cid: @event.cid
      assert_response :success
    end

    should 'create mass action' do
      post :mass_action, use_sig_id: 1, sig_id: @event.signature.sig_id,
                         classification_id: @classification.id,
                         use_ip_src: 1, use_ip_dst: 1,
                         sensor_ids: [@event.sid], reclassify: 1,
                         format: :js
      assert_response :success
    end

    should 'export event to json' do
      post :export, events: "#{@event.sid}-#{@event.cid}", format: :json
      assert_response :success
    end

    should 'get history' do
      get :history
      assert_response :success
    end

    should 'classify events' do
      post :classify, events: "#{@event.sid}-#{@event.cid}",
                      classification: @classification.id
      assert_response :success
    end

    should 'classify events by session' do
      post :classify_sessions, events: "#{@event.sid}-#{@event.cid}",
                               classification: @classification.id
      assert_response :success
    end

    should 'get last event' do
      get :last
      assert_response :success
    end

    should 'get events from 1 hour ago' do
      get :since, timestamp: Time.now - 1.hour
      assert_response :success
    end

    should 'make event as favorite' do
      assert_difference('Favorite.count', 1) do
        post :favorite, sid: @event.sid, cid: @event.cid
      end

      assert_response :success
    end

    should 'delete event as favorite' do
      assert_difference('Favorite.count', -1) do
        post :favorite, sid: @event_2.sid, cid: @event_2.cid
      end

      assert_response :success
    end

    should 'lookup event source IP' do
      Setting.stubs(:lookups?).returns(true)
      get :lookup, address: @event.ip.ip_src
      assert_response :success
    end

    should 'not lookup event IP if setting disabled' do
      Setting.stubs(:lookups?).returns(false)
      get :lookup, address: @event.ip.ip_dst
      assert(response.body, '<div id="note-box">This feature has be disabled</div>')
    end

    should "get user's activity" do
      get :activity, user_id: @user.id
      assert_response :success
    end

    should 'get hotkeys' do
      get :hotkey
      assert_response :success
    end

    should 'get packet capture form' do
      get :packet_capture, sid: @event.sid, cid: @event.cid
      assert_response :success
    end
  end
end
