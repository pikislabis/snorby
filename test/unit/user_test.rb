require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many(:notifications)
  should have_many(:favorites)
  should have_many(:notes)
  should have_many(:saved_searches)
  should have_many(:events)

  context 'Admin user' do
    setup do
      @admin = users(:admin)
    end

    should 'be notified when adding notes' do
      assert @admin.accepts_note_notifications?
    end

    should 'send daily report' do
      @admin.send_daily_report
      assert !ActionMailer::Base.deliveries.empty?
    end

    should 'send weekly report' do
      @admin.send_weekly_report
      assert !ActionMailer::Base.deliveries.empty?
    end

    should 'send monthly report' do
      @admin.send_monthly_report
      assert !ActionMailer::Base.deliveries.empty?
    end
  end

  context 'Normal user' do
    setup do
      @user = users(:user)
      @event_1 = events(:one)
      @event_2 = events(:two)
    end

    should 'be notified only events he has noted' do
      assert_not @user.accepts_note_notifications?(@event_1)
      assert @user.accepts_note_notifications?(@event_2)
    end
  end

  context 'Normal user' do
    setup do
      @user = users(:user_2)
    end

    should 'not be notified' do
      assert_not @user.accepts_note_notifications?
    end
  end
end
