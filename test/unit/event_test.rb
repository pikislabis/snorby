require 'test_helper'

class EventTest < ActiveSupport::TestCase
  context 'Event instance' do
    setup do
      @event = events(:one)
    end

    should 'not be hids' do
      assert_not @event.hids?
    end

    should 'decrement classification count when being destoyed' do
      assert_difference '@event.classification.events_count', -1 do
        @event.destroy
      end
    end

    should 'decrement signature count when being destroyed' do
      assert_difference '@event.signature.events_count', -1 do
        @event.destroy
      end
    end
  end

  context 'Event class' do
    should 'return last timestamp' do
      event = Event.create(sensor: sensors(:one), cid: rand(1000), timestamp: 1.minute.ago)
      assert_equal Event.last_event_timestamp.to_s(:db), event.timestamp.to_s(:db)
    end

    should 'return unique events by source IP' do
      assert Event.unique_events_by_source_ip.is_a? Array
    end
  end
end
