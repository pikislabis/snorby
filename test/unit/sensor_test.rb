require 'test_helper'

class SensorTest < ActiveSupport::TestCase
  context 'A registered sensor' do
    setup do
      @sensor = sensors(:one)
    end

    should 'gets its caches' do
      assert_equal @sensor.cache.count, Cache.where(sid: @sensor.id).count
    end

    should 'return its name' do
      assert_equal @sensor.sensor_name, @sensor.name
    end

    should 'gets its daily caches' do
      assert_equal @sensor.daily_cache.count,
                   DailyCache.where(sid: @sensor.id).count
    end
  end

  context 'A new sensor' do
    setup do
      @sensor = sensors(:two)
    end

    should 'returns hostname instead of name' do
      assert_equal @sensor.sensor_name, @sensor.hostname
    end
  end
end
