require 'snorby/jobs/alert_notifications'
require 'snorby/jobs/cache_helper'
require 'snorby/jobs/daily_cache_job'
require 'snorby/jobs/event_mailer_job'
require 'snorby/jobs/note_notification'
require 'snorby/jobs/mass_classification'
require 'snorby/jobs/sensor_cache_job'

class DelayedJob < ActiveRecord::Base

  # TODO
  # def self.find
  #   Delayed::Backend::DataMapper::Job
  # end

  def self.run(obj, priority=1, time=Time.now)
    Delayed::Job.enqueue(obj, :priority => priority, :run_at => time)
  end

  def self.start
    Jobs::SensorCacheJob.new(false).perform unless Jobs.sensor_cache?
    # Jobs::DailyCacheJob.new(false).perform unless Jobs.daily_cache?
    Jobs::GeoipUpdatedbJob.new(false).perform if (Setting.geoip? && !Jobs.geoip_update?)
  end

  def self.sensor_cache
    where('handler like ?',
          '%!ruby/struct:Snorby::Jobs::SensorCacheJob%').first
  end

  def self.daily_cache
    where('handler like ?',
          '%!ruby/struct:Snorby::Jobs::DailyCacheJob%').first
  end

  def self.geoip_update
    where('handler like ?',
          '%!ruby/struct:Snorby::Jobs::GeoipUpdatedbJob%').first
  end

  def self.sensor_cache?
    where('handler like ?',
          '%!ruby/struct:Snorby::Jobs::SensorCacheJob%').present?
  end

  def self.daily_cache?
    where('handler like ?',
          '%!ruby/struct:Snorby::Jobs::DailyCacheJob%').present?
  end

  def self.geoip_update?
    where('handler like ?',
          '%!ruby/struct:Snorby::Jobs::GeoipUpdatedbJob%').present?
  end

  def self.sensor_caching?
    return true if sensor_cache? && sensor_cache.locked_at
    false
  end

  def self.daily_caching?
    return true if daily_cache? && daily_cache.locked_at
    false
  end

  def self.geoip_updating?
    return true if geoip_update? && geoip_update.locked_at
    false
  end

  def self.caching?
    return true if (sensor_caching? || daily_caching?)
    false
  end

  def self.reset_counters
    Sensor.all.each do |sensor|
      sensor.update(:events_count => Event.all(:sid => sensor.sid).count)
    end
    Signature.all.each do |sig|
      sig.update(:events_count => Event.all(:sig_id => sig.sig_id).count)
    end
    Classification.all.each do |classification|
      classification.update(:events_count => Event.all(:classification_id => classification.id).count)
    end
    Severity.all.each do |sev|
      sev.update(:events_count => Event.all(:"signature.sig_priority" => sev.sig_id).count)
    end
    nil
  end

  def self.reset_cache(type, verbose=true)
    case type.to_sym
    when :sensor
      Cache.all.destroy!
      Snorby::Jobs::SensorCacheJob.new(verbose).perform
    when :daily
      DailyCache.all.destroy!
      Snorby::Jobs::DailyCacheJob.new(verbose).perform
    when :all
      Cache.all.destroy!
      DailyCache.all.destroy!
      Snorby::Jobs::SensorCacheJob.new(verbose).perform
      Snorby::Jobs::DailyCacheJob.new(verbose).perform
    end
  end

  def self.run_now!
    Delayed::Job.enqueue(Snorby::Jobs::SensorCacheJob.new(false),
    :priority => 1, :run_at => DateTime.now + 5.second)

    # Delayed::Job.enqueue(Snorby::Jobs::DailyCacheJob.new(false),
    # :priority => 1, :run_at => DateTime.now + 5.second)

    Delayed::Job.enqueue(Snorby::Jobs::GeoipUpdatedbJob.new,
    :priority => 1, :run_at => DateTime.now + 5.second)
  end

  def self.force_sensor_cache
    if DelayedJob.sensor_cache?
      DelayedJob.sensor_cache.update(run_at: DateTime.now + 5.second)
    else
      Delayed::Job.enqueue(Snorby::Jobs::SensorCacheJob.new(false),
                           priority: 1, run_at: DateTime.now + 5.second)
    end
  end


  def self.clear_cache(are_you_sure=false)
    if are_you_sure
      Cache.all.destroy!
      DailyCache.all.destroy!
    end
  end
end
