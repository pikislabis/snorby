class Cache < ActiveRecord::Base

  # property :id, Serial
  #
  # property :sid, Integer
  #
  # property :cid, Integer
  #
  # property :ran_at, ZonedTime
  #
  # property :event_count, Integer, :default => 0
  #
  # property :tcp_count, Integer, :default => 0
  #
  # property :udp_count, Integer, :default => 0
  #
  # property :icmp_count, Integer, :default => 0
  #
  # property :severity_metrics, Object
  #
  # property :signature_metrics, Object
  #
  # property :src_ips, Object
  #
  # property :dst_ips, Object
  #
  # # Define created_at and updated_at timestamps
  # timestamps :at
  # property :created_at, ZonedTime
  # property :updated_at, ZonedTime

  serialize :severity_metrics, Hash
  serialize :signature_metrics, Hash
  serialize :src_ips, Hash
  serialize :dst_ips, Hash

  belongs_to :sensor, foreign_key: :sid, primary_key: :sid

  has_one :event, foreign_key: [:sid, :cid], primary_key: [:sid, :cid]

  scope :last_month, -> { where('ran_at >= ? AND ran_at <= ?', (Time.zone.now - 2.months).beginning_of_month, (Time.zone.now - 2.months).end_of_month) }

  scope :this_quarter, -> { where('ran_at >= ? AND ran_at <= ?', Time.zone.now.beginning_of_quarter, Time.zone.now.end_of_quarter) }

  scope :this_month, -> { where('ran_at >= ? AND ran_at <= ?', Time.zone.now.beginning_of_month, Time.zone.now.end_of_month) }

  scope :last_week, -> { where('ran_at >= ? AND ran_at <= ?', (Time.zone.now - 1.weeks).beginning_of_week, (Time.zone.now - 1.weeks).end_of_week) }

  scope :this_week, -> { where('ran_at >= ? AND ran_at <= ?', Time.zone.now.beginning_of_week, Time.zone.now.end_of_week) }

  scope :yesterday, -> { where('ran_at >= ? AND ran_at <= ?', Time.zone.now.yesterday.beginning_of_day, Time.zone.now.yesterday.end_of_day) }

  scope :today, -> { where('ran_at >= ? AND ran_at <= ?', Time.zone.now.beginning_of_day, Time.zone.now.end_of_day) }

  def self.last_24(first = nil, last = nil)
    current = Time.zone.now
    end_time = last ? last : current
    start_time = first ? first : current.yesterday

    where('ran_at >= ? AND ran_at <= ?', start_time, end_time)
  end

  def self.cache_time
    get_last.try('updated_at') || Time.zone.now
  end

  def self.protocol_count(protocol, type = nil)
    count = count_hash(type)

    @cache = cache_for_type(:hour)

    case protocol.to_sym
    when :tcp
      @cache.each do |hour, data|
        count[hour] = data.map(&:tcp_count).sum
      end
    when :udp
      @cache.each do |hour, data|
        count[hour] = data.map(&:udp_count).sum
      end
    when :icmp
      @cache.each do |hour, data|
        count[hour] = data.map(&:icmp_count).sum
      end
    end

    count.values
  end

  def self.severity_count(severity, type = nil)
    count = count_hash(type)

    @cache = cache_for_type(:hour)

    case severity.to_sym
    when :high
      @cache.each do |hour, data|
        high_count = 0
        data.map(&:severity_metrics).each { |x| high_count += (x.is_a?(Hash) ? (x.key?(1) ? x[1] : 0) : 0) }
        count[hour] = high_count
      end
    when :medium
      @cache.each do |hour, data|
        medium_count = 0
        data.map(&:severity_metrics).each { |x| medium_count += (x.is_a?(Hash) ? (x.key?(2) ? x[2] : 0) : 0) }
        count[hour] = medium_count
      end
    when :low
      @cache.each do |hour, data|
        low_count = 0
        data.map(&:severity_metrics).each { |x| low_count += ( x.is_a?(Hash) ? (x.key?(3) ? x[3] : 0) : 0) }
        count[hour] = low_count
      end
    end

    count.values
  end

  def self.get_last
    all.order(updated_at: :desc).first
  end

  def self.sensor_metrics(type = nil)
    @metrics = []

    Sensor.all.limit(5).order(events_count: :desc).each do |sensor|
      if type == :custom
        count = {} # count_hash(type)

        blah = all.where(sid: sensor.sid).group_by do |x|
          time = x.ran_at
          "#{time.year}-#{time.month}-#{time.day}-#{time.hour}"
        end

        blah.each do |hour, data|
          count[hour] = data.map(&:event_count).sum
        end

        @metrics << {
          name: sensor.sensor_name,
          data: count.values,
          range: count.keys.collect { |x| "'#{x.split('-')[2]}'" }
        }

      else # if not custom

        count = count_hash(type)

        blah = all.where(sid: sensor.sid).group_by { |x| "#{x.ran_at.day}-#{x.ran_at.hour}" }

        blah.each do |hour, data|
          count[hour] = data.map(&:event_count).sum
        end

        @metrics << {
          name: sensor.sensor_name,
          data: count.values,
          range: count.keys.collect { |x| "'#{x.split('-').last}'" }
        }

      end # custom logic
    end

    @metrics
  end

  def self.src_metrics(limit = 20)
    @metrics = {}
    @top = []
    @cache = pluck(:src_ips).compact

    @cache.each do |ip_hash|
      ip_hash.each do |ip, count|
        if @metrics.key?(ip)
          @metrics[ip] += count
        else
          @metrics.merge!(ip => count)
        end
      end
    end

    count = 0

    @metrics.sort { |a, b| b[1] <=> a[1] }.each do |data|
      break if count >= limit
      @top << data
      count += 1
    end

    @top
  end

  def self.dst_metrics(limit = 20)
    @metrics = {}
    @top = []
    @cache = pluck(:dst_ips).compact

    @cache.each do |ip_hash|
      ip_hash.each do |ip, count|
        if @metrics.key?(ip)
          @metrics[ip] += count
        else
          @metrics.merge!(ip => count)
        end
      end
    end

    count = 0

    @metrics.sort { |a, b| b[1] <=> a[1] }.each do |data|
      break if count >= limit
      @top << data
      count += 1
    end

    @top
  end

  def self.signature_metrics(limit = 20)
    @metrics = {}
    @top = []
    @cache = pluck(:signature_metrics).compact

    @cache.each do |data|
      data.each do |id, value|
        if @metrics.key?(id)
          temp_count = @metrics[id]
          @metrics.merge!(id => temp_count + value)
        else
          @metrics.merge!(id => value)
        end
      end
    end

    count = 0

    @metrics.sort { |a, b| b[1] <=> a[1] }.each do |data|
      break if count >= limit
      @top << data
      count += 1
    end

    @top
  end

  def self.count_hash(type = nil)
    count = {}

    if type == :last_24
      now = Time.zone.now
      # TODO
      # this will need to store the key as day/hour

      Range.new(now.yesterday.to_i, now.to_i).step(1.hour) do |seconds_since_epoch|
        time = Time.zone.at(seconds_since_epoch)
        key = "#{time.day}-#{time.hour}"
        count[key] = 0
      end

    elsif type == :custom
      time_start = Time.zone.now.yesterday.beginning_of_day.to_i
      time_end = Time.zone.now.yesterday.end_of_day.to_i

      Range.new(time_start, time_end).step(1.day) do |seconds_since_epoch|
        time = Time.zone.at(seconds_since_epoch)
        key = "#{time.year}-#{time.month}-#{time.day}-#{time.hour}"
        count[key] = 0
      end
    else # if not custom
      if type == :today
        time_start = Time.zone.now.beginning_of_day.to_i
        time_end = Time.zone.now.end_of_day.to_i
      else
        time_start = Time.zone.now.yesterday.beginning_of_day.to_i
        time_end = Time.zone.now.yesterday.end_of_day.to_i
      end

      Range.new(time_start, time_end).step(1.hour) do |seconds_since_epoch|
        time = Time.zone.at(seconds_since_epoch)
        key = "#{time.day}-#{time.hour}"
        count[key] = 0
      end
    end

    count
  end

  def self.cache_for_type(_type, sensor = false)
    return all.group_by { |x| "#{x.ran_at.day}-#{x.ran_at.hour}" } unless sensor
    where(sid: sensor.sid).group_by do |x|
      "#{x.ran_at.day}-#{x.ran_at.hour}"
    end
  end
end
