class Sensor < ActiveRecord::Base
  self.table_name = 'sensor'

  # property :sid, Serial, :key => true, :index => true, :min => 0
  #
  # property :name, String, :default => 'Click To Change Me'
  #
  # property :hostname, Text, :index => true
  #
  # property :interface, Text
  #
  # property :filter, Text
  #
  # property :detail, Integer, :index => true, :min => 0
  #
  # property :encoding, Integer, :index => true, :min => 0
  #
  # property :last_cid, Integer, :index => true, :min => 0
  #
  # property :pending_delete, Boolean, :default => false
  #
  # property :updated_at, ZonedTime
  #
  # property :events_count, Integer, :index => true, :default => 0, :min => 0

  has_many :agent_asset_names

  has_many :asset_names, through: :agent_asset_names

  has_many :metrics, class_name: 'Cache', :foreign_key => :sid, :dependent => :destroy

  has_many :daily_metrics, class_name: 'DailyCache', :foreign_key => :sid, :dependent => :destroy

  has_many :events, :foreign_key => :sid, :dependent => :destroy

  has_many :ips, :foreign_key => :sid, :dependent => :destroy

  has_many :notes, :foreign_key => :sid, :dependent => :destroy

  def cache
    Cache.all(:sid => sid)
  end

  def sensor_name
    return name unless name == 'Click To Change Me'
    hostname
  end

  def daily_cache
    DailyCache.all(:sid => sid)
  end

  def last
    return Event.find_by(sid: sid, cid: last_cid) unless last_cid.blank?
    false
  end

  #
  #
  #
  def event_percentage
    begin
      total_event_count = Sensor.all.map(&:events_count).sum
      return 0 if total_event_count.zero?
      "%.2f" % ((self.events_count.to_f / total_event_count.to_f) * 100).round(1)
    rescue FloatDomainError
      0
    end
  end


end
