require 'test_helper'

class CacheTest < ActiveSupport::TestCase
  context 'Caches' do
    should 'get cache time' do
      last_cache = Cache.select(:updated_at).order(updated_at: :desc).first
      assert_equal Cache.cache_time, last_cache.updated_at
    end

    should 'get tcp count in last 24 hours' do
      tcp_count = Cache.where('updated_at between ? and ?', Time.now.yesterday, Time.now).sum(:tcp_count)
      assert_equal Cache.protocol_count(:tcp, :last_24).sum, tcp_count
    end

    should 'get src metrics' do
      src_metrics = Cache.src_metrics
      assert src_metrics.is_a? Array
      assert src_metrics.map { |x| x[1] }.sum <= 20
    end

    should 'get signature metrics' do
      signature_metrics = Cache.signature_metrics
      assert signature_metrics.is_a? Array
      assert signature_metrics.map { |x| x[1] }.sum <= 20
    end

    should 'return cache grouped by hour' do
      grouped_caches = Cache.cache_for_type(:hour)
      assert grouped_caches.is_a? Hash
    end

    should 'return cache grouped by hour for one sensor' do
      grouped_caches = Cache.cache_for_type(:hour, sensors(:two))
      assert grouped_caches.is_a? Hash
    end
  end
end
