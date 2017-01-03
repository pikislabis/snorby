require 'netaddr'
require 'csv'

class Event < ActiveRecord::Base
  #
  # Cache Helpers
  #
  extend Snorby::Jobs::CacheHelper

  # Included for the truncate helper method.
  extend ActionView::Helpers::TextHelper

  SIGNATURE_URL = "http://rootedyour.com/snortsid?sid=$$gid$$-$$sid$$"

  self.table_name = 'event'
  self.inheritance_column = ''

  self.primary_keys = :sid, :cid

  # property :sid, Integer, :key => true, :index => true, :min => 0
  #
  # property :cid, Integer, :key => true, :index => true, :min => 0
  #
  # property :sig_id, Integer, :field => 'signature', :index => true, :min => 0
  #
  # property :classification_id, Integer, :index => true, :required => false, :min => 0
  #
  # property :users_count, Integer, :index => true, :default => 0, :min => 0
  #
  # property :user_id, Integer, :index => true, :required => false, :min => 0
  #
  # property :notes_count, Integer, :index => true, :default => 0, :min => 0

  # 1 = nids
  # 2 = hids
  # others TBD
  # property :type, Integer, :default => 1, :min => 0

  # Fake Column
  # property :number_of_events, Integer, :default => 0, :min => 0
  #
  # property :event_id, Integer
  ###

  belongs_to :classification

  # property :timestamp, ZonedTime

  has_many :favorites, foreign_key: [:sid, :cid], dependent: :destroy

  has_many :users, through: :favorites

  has_one :severity, through: :signature, foreign_key: :sig_priority

  has_one :payload, foreign_key: [:sid, :cid], dependent: :destroy

  has_one :icmp, foreign_key: [:sid, :cid], dependent: :destroy

  has_one :tcp, foreign_key: [:sid, :cid], dependent: :destroy

  has_one :udp, foreign_key: [:sid, :cid], dependent: :destroy

  has_one :opt, foreign_key: [:sid, :cid], dependent: :destroy

  has_many :notes, foreign_key: [:sid, :cid], dependent: :destroy

  belongs_to :user

  belongs_to :sensor, foreign_key: :sid, required: true

  belongs_to :signature, foreign_key: :signature

  belongs_to :ip, foreign_key: [:sid, :cid]

  before_destroy do
    classification.decrement(:events_count) if classification
    signature.decrement(:events_count) if signature
    # Note: Need to decrement Severity, Sensor and User Counts
  end

  default_scope { order(sid: :ASC, cid: :ASC) }

  SORT = {
    sig_priority: 'signature',
    sid: 'event',
    ip_src: 'ip',
    ip_dst: 'ip',
    sig_name: 'signature',
    timestamp: 'event',
    user_count: 'event',
    number_of_events: 'event'
  }.freeze

  def self.last_event_timestamp
    event = unscoped.all.order(timestamp: :desc).first
    event ? event.timestamp : Time.zone.now
  end

  def hids?
    signature.name =~ /\[HIDS\]/
  end

  def helpers
    ActionController::Base.helpers
  end

  def self.unique_events_by_source_ip
    data = []

    ips = Ip.limit(25).distinct.pluck(:ip_src)
    events = ips.collect do |ip|
      Event.includes(:ip).where(iphdr: { ip_src: ip }).order(timestamp: :desc).group_by do |x|
        x.signature
      end
    end

    events.each do |set|
      next if set.blank?
      next if set.values.blank?

      set.each do |_key, value|
        data << value.first
      end
    end

    data
  end

  def self.sorty(params = {}, sql = false, count = false)
    sort = params[:sort]
    direction = params[:direction]

    page = {
      per_page: (params[:limit] ? params[:limit].to_i : User.current_user.per_page_count.to_i)
    }

    if params.key?(:search)
      sql, _count = Snorby::Search.build(params[:match_all], false, params[:search])

      sql[0] += " order by #{sort} #{direction}"

      paginate_by_sql(
        sql,
        page: params[:page],
        per_page: page[:per_page]
      )
    elsif sql

      paginate_by_sql(
        sql[0],
        page: params[:page],
        per_page: page[:per_page]
      )

    else

      if SORT[sort].casecmp 'event'
        page[:order] = '#{sort} #{direction}'
      else
        page[:order] = [Event.send(SORT[sort].to_sym).send(sort).send(direction),
                        :timestamp.send(direction)]
        page[:link] = [Event.relationships[SORT[sort].to_s].inverse]
      end

      page[:classification_id] = nil unless params.key?(:classification_all)

      if params.key?(:user_events)
        relationship = Event.relationships['user'].inverse

        if page.key?(:links)
          page[:links].push(relationship)
        else
          page[:links] = [relationship]
        end
      end

      paginate(page: (params[:page] || 1).to_i, per_page: page[:per_page])
    end
  end

  def packet_capture(params = {})
    case Setting.find(:packet_capture_type).to_sym
    when :openfpc
      Snorby::Plugins::OpenFPC.new(self, params).to_s
    when :solera
      Snorby::Plugins::Solera.new(self, params).to_s
    end
  end

  def signature_url
    sid, gid = [/\$\$sid\$\$/, /\$\$gid\$\$/]

    @signature_url = if Setting.signature_lookup?
                       Setting.find(:signature_lookup)
                     else
                       SIGNATURE_URL
                     end

    @signature_url.sub(sid, signature.sig_sid.to_s).sub(gid, signature.sig_gid.to_s)
  end

  def matches_notification?
    Notification.each do |notify|
      next unless notify.sig_id == sig_id
      send_notification if notify.check(self)
    end
    nil
  end

  def send_notification
    Delayed::Job.enqueue(Snorby::Jobs::AlertNotifications.new(sid, cid))
  end

  def self.limit(limit = 25)
    all.limit(limit)
  end

  def secondary_id
    "#{sid}_#{cid}"
  end

  def to_param
    "#{sid},#{cid}"
  end

  def self.last_month
    all(:timestamp.gte => 2.month.ago.beginning_of_month,
        :timestamp.lte => 1.month.ago.end_of_month)
  end

  def self.last_week
    all(:timestamp.gte => 2.week.ago.beginning_of_week,
        :timestamp.lte => 1.week.ago.end_of_week)
  end

  def self.yesterday
    all(:timestamp.gte => 1.day.ago.beginning_of_day,
        :timestamp.lte => 1.day.ago.end_of_day)
  end

  def self.today
    all(:timestamp.gte => Time.now.beginning_of_day,
        :timestamp.lte => Time.now.end_of_day)
  end

  def self.find_classification(classification_id)
    where(classification_id: classification_id)
  end

  def self.find_signature(sig_id)
    where(sig_id: sig_id)
  end

  def self.find_sensor(sensor)
    where(sensor: sensor)
  end

  def self.between(start_time, end_time)
    all(:timestamp.gte => start_time, :timestamp.lte => end_time,
        order: [:timestamp.desc])
  end

  def self.between_time(start_time, end_time)
    all(:timestamp.gte => start_time, :timestamp.lt => end_time,
        order: [:timestamp.desc])
  end

  def self.update_classification_by_session(ids, classification, user_id = nil)
    event_count = 0

    @classification = if classification.to_i.zero?
                        'NULL'
                      else
                        Classification.find(classification.to_i).id
                      end

    uid = if user_id
            user_id
          else
            User.current_user.id
          end

    if @classification
      update = "UPDATE event SET `classification_id` = #{@classification}, \
                `user_id` = #{uid} WHERE "
      event_data = ids.split(',')
      sql = 'select * from event where '
      events = []

      event_data.each do |e|
        event = e.split('-')
        event_count += 1

        events.push("(sid = #{event.first.to_i} and cid = #{event.last.to_i})")
      end

      sql += events.join(' OR ')
      @events = Event.find_by_sql(sql)

      classification_sql = []
      @events.each do |event|
        classification_sql.push("(classification_id is NULL AND \
                                  sid = #{event.sid} AND cid = #{event.cid})")
      end

      tmp = update + classification_sql.join(' OR ')

      db_execute(tmp)
      db_execute("update classifications \
                  set events_count = (select count(*) \
                  from event \
                  where event.`classification_id` = classifications.id);")

      event_count
    end
  end

  def self.update_classification(ids, classification, user_id = nil)
    event_count = 0

    @classification = if classification.to_i.zero?
                        'NULL'
                      else
                        Classification.find(classification.to_i)
                      end

    uid = if user_id
            user_id
          else
            User.current_user.id
          end

    if @classification
      update = "UPDATE `event` SET `classification_id` = #{(@classification == "NULL" ? @classification : @classification.id)}, `user_id` = #{uid} WHERE "
      events = []

      process = lambda do |e|
        event_data = e.split(',')

        event_data.each_with_index do |ev, index|
          event_count += 1

          event = ev.split('-')
          events.push("(`sid` = #{event.first.to_i} and `cid` = #{event.last.to_i})")

          next unless ((index + 1) % 10_000) == 0

          tmp = update
          tmp += events.join(' OR ')
          tmp += ';'
          db_execute(tmp)
          events = []
        end

        unless events.empty?
          tmp = update
          tmp += events.join(' OR ')
          tmp += ';'
          db_execute(tmp)
          events = []
        end

        db_execute('update classifications set events_count = (select count(*) from event where event.`classification_id` = classifications.id);')
        event_count
      end

      if ids.is_a?(Array)
        process.call(ids.first)
      else
        process.call(ids)
      end

    end
  end

  def self.find_by_ids(ids)
    events = []
    ids.split(',').collect do |e|
      event = e.split('-')
      events << find_by(sid: event.first, cid: event.last)
    end

    events
  end

  def data_id
    "#{sid}-#{cid}"
  end

  def html_id
    "event_#{sid}#{cid}"
  end

  def json_time
    "{time:'#{timestamp}'}"
  end

  def pretty_time
    # if Setting.utc?
      # return "#{timestamp.utc.strftime('%H:%M')}" if Date.today.to_date == timestamp.to_date
      # "#{timestamp.strftime('%m/%d/%Y')}"
    # else
      # return "#{timestamp.strftime('%l:%M %p')}" if Date.today.to_date == timestamp.to_date
      # "#{timestamp.strftime('%m/%d/%Y')}"
    # end
    return timestamp.strftime('%l:%M %p').to_s if Time.zone.today.to_date == timestamp.to_date
    timestamp.strftime('%m/%d/%Y').to_s
  end

  def detailed_json
    geoip = Setting.geoip?
    ip = self.ip

    event = {
      sid: sid,
      cid: cid,
      hostname: sensor.sensor_name,
      severity: signature.sig_priority,
      session_count: number_of_events,
      ip_src: self.ip.ip_src.to_s,
      ip_dst: self.ip.ip_dst.to_s,
      asset_names: self.ip.asset_names,
      timestamp: pretty_time,
      datetime: timestamp.strftime('%A, %b %d, %Y at %I:%M:%S %p'),
      message:  signature.name,
      geoip: false,
      src_port: src_port,
      dst_port: dst_port,
      users_count: users_count,
      notes_count: notes_count,
      sig_id: signature.sig_id,
      favorite: favorite?

    }

    if geoip
      event.merge!(geoip: true, src_geoip: ip.geoip[:source],
                   dst_geoip: ip.geoip[:destination])
    end

    event
  end

  #
  # To Json From Time Range
  #
  # This method will likely be deprecated
  # in favor of .to_json(:include). Due to
  # the snort schema being legacy this was
  # needed for the time being.
  #
  # @param [String] time Start time
  #
  # @return [Hash] hash of events between range.
  #
  def self.to_json_since(time)
    time ||= Time.zone.now

    geoip = Setting.geoip?
    events = Event.where(classification_id: nil)
                  .where('timestamp > ?', Time.zone.parse(time.to_s))
                  .order(timestamp: :desc)
    json = { events: [] }

    events.each do |event|
      ip = event.ip

      event = {
        sid: event.sid,
        cid: event.cid,
        hostname: event.sensor.sensor_name,
        severity: event.signature.sig_priority,
        ip_src: ip.ip_src.to_s,
        ip_dst: ip.ip_dst.to_s,
        timestamp: event.pretty_time,
        datetime: event.timestamp.strftime('%A, %b %d, %Y at %I:%M:%S %p'),
        message: event.signature.name,
        geoip: false
      }

      if geoip
        event.merge!(geoip: true, src_geoip: ip.geoip[:source],
                     dst_geoip: ip.geoip[:destination])
      end

      json[:events] << event
    end

    json
  end

  def favorite?
    return true if User.current_user.events.to_a.include?(self)
    false
  end

  def toggle_favorite
    if favorite?
      destroy_favorite
    else
      create_favorite
    end
  end

  def create_favorite
    Favorite.create(sid: sid, cid: cid, user: User.current_user)
  end

  def destroy_favorite
    favorite = User.current_user.favorites.find_by(sid: sid, cid: cid)
    favorite.destroy! if favorite
  end

  def protocol
    return :tcp if tcp?
    return :udp if udp?
    return :icmp if icmp?
    nil
  end

  def protocol_data
    return [:tcp, tcp] if tcp?
    return [:udp, udp] if udp?
    return [:icmp, icmp] if icmp?
    false
  end

  def source_port
    return nil unless protocol_data

    if protocol_data.first == :icmp
      nil
    else
      protocol_data.last.send(:"#{protocol_data.first}_sport")
    end
  end

  def rule
    @rule = Snorby::Rule.get(
      rule_id: signature.sig_sid,
      generator_id: signature.sig_gid,
      revision_id: signature.sig_rev
    )

    @rule if @rule.found?
  end

  def destination_port
    return nil unless protocol_data

    if protocol_data.first == :icmp
      nil
    else
      protocol_data.last.send(:"#{protocol_data.first}_dport")
    end
  end

  def in_xml
    %(
      <snorby>
        #{to_xml(skip_instruct: true)}
        #{ip.to_xml(skip_instruct: true)}
        #{protocol_data.last.to_xml(skip_instruct: true) if protocol_data}
        #{classification.to_xml(skip_instruct: true) if classification}
        #{payload.to_xml(skip_instruct: true) if payload}
      </snorby>
    ).chomp
  end

  def in_json
    type, proto = protocol_data
    {
      sid: sid,
      cid: cid,
      ip: ip,
      src_ip: ip.ip_src.to_s,
      src_port: src_port,
      dst_ip: ip.ip_dst.to_s,
      dst_port: dst_port,
      type: type,
      proto: proto,
      payload: payload,
      payload_html: payload ? payload.to_html : '',
      sensor: sensor,
      favorite: favorite?
    }
  end

  #
  # ICMP
  #
  # @return [Boolean] return true
  # if the event proto was icmp.
  #
  def icmp?
    return true unless icmp.blank?
    false
  end

  #
  # TCP
  #
  # @retrun [Boolean] return true
  # if the event proto is tcp.
  #
  def tcp?
    return true unless tcp.blank?
    false
  end

  #
  # UDP
  #
  # @return [Boolean] return true
  # if the event proto is udp.
  #
  def udp?
    return true unless udp.blank?
    false
  end

  #
  # Event Source Port
  #
  # @return [Boolean] return the source
  # port for the event if available.
  #
  def src_port
    return 0 if icmp?
    return tcp.tcp_sport if tcp?
    return udp.udp_sport if udp?
    nil
  end

  #
  # Event Destination Port
  #
  # @return [Boolean] return the sestination
  # port for the event if available.
  #
  def dst_port
    return 0 if icmp?
    return tcp.tcp_dport if tcp?
    return udp.udp_dport if udp?
    nil
  end

  def self.classify_from_collection(events, classification, user, reclassify = false)
    @classification = Classification.get(classification)
    @user = User.get(user)

    events.each do |event|
      old_classification = event.classification if event.classification.present?

      next if old_classification == @classification
      next if old_classification && reclassify == false

      event.classification = @classification
      event.user_id = @user.id

      if event.save
        @classification.up(:events_count) if @classification
        old_classification.down(:events_count) if old_classification
      else
        Rails.logger.info "ERROR: #{event.errors.inspect}"
      end
    end
  rescue => e
    Rails.logger.info(e.backtrace)
  end

  def self.build_search_hash(column, operator, value)
    ["#{column} #{operator}", value]
  end

  def self.search(params, _pager = {})
    @search = {}
    search = []
    sql = []
    params.each do |_key, v|
      column = v['column'].to_sym
      operator = v['operator'].to_sym
      value = v['value']

      if column == :protocol
      else
        sql.push(build_search_hash(SEARCH[column], OPERATOR[operator], value.to_i))
      end
    end

    search.push sql.collect(&:first).join(' AND ')
    search.push(sql.collect(&:last).flatten).flatten!

    p search

    @search.merge!({sid: params[:sid].to_i}) unless params[:sid].blank?

    unless params[:classification_id].blank?
      if params[:classification_id].to_i == 0
        @search.merge!({classification_id: nil})
      else
        @search.merge!({classification_id: params[:classification_id].to_i})
      end
    end

    unless params[:signature_name].blank?
      @search.merge!({
        :"signature.sig_name".like => "%#{params[:signature_name]}%"
      })
    end

    unless params[:src_port].blank?
      @search.merge!({:"tcp.tcp_sport" => params[:src_port].to_i})
    end

    unless params[:dst_port].blank?
      @search.merge!({:"tcp.tcp_dport" => params[:dst_port].to_i})
    end

    ### IPAddr
    unless params[:ip_src].blank?
      if params[:ip_src].match(/\d+\/\d+/)
        range = NetAddr::CIDR.create("#{params[:ip_src]}")
        @search.merge!({
          :"ip.ip_src".gte => IPAddr.new(range.first),
          :"ip.ip_src".lte => IPAddr.new(range.last),
        })
      else
        @search.merge!({:"ip.ip_src".like => IPAddr.new("#{params[:ip_src]}")})
      end
    end

    unless params[:ip_dst].blank?
      if params[:ip_dst].match(/\d+\/\d+/)
        range = NetAddr::CIDR.create("#{params[:ip_dst]}")
        @search.merge!({
          :"ip.ip_dst".gte => IPAddr.new(range.first),
          :"ip.ip_dst".lte => IPAddr.new(range.last),
        })
      else
        @search.merge!({:"ip.ip_dst".like => IPAddr.new("#{params[:ip_dst]}")})
      end
    end

    unless params[:severity].blank?
      @search.merge!({:"signature.sig_priority" => params[:severity].to_i})
    end

    # Timestamp
    if params[:timestamp].blank?

      unless params[:time_start].blank? || params[:time_end].blank?
        @search.merge!({
          conditions: ['timestamp >= ? AND timestamp <= ?',
            Time.at(params[:time_start].to_i),
            Time.at(params[:time_end].to_i)
        ]})
      end

    else

      if params[:timestamp] =~ /\s\-\s/
        start_time, end_time = params[:timestamp].split(' - ')
        @search.merge!({conditions: ['timestamp >= ? AND timestamp <= ?',
                       Chronic.parse(start_time).beginning_of_day,
                       Chronic.parse(end_time).end_of_day]})
      else
        @search.merge!({conditions: ['timestamp >= ? AND timestamp <= ?',
                       Chronic.parse(params[:timestamp]).beginning_of_day,
                       Chronic.parse(params[:timestamp]).end_of_day]})
      end

    end

    unless params[:severity].blank?
      @search.merge!({:"signature.sig_priority" => params[:severity].to_i})
    end

    search

  rescue NetAddr::ValidationError
    {}
  rescue ArgumentError
    {}
  end

  def to_csv
    CSV.generate do |csv|
      csv << Event.attribute_names
      csv << attributes.values
    end
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << Event.attribute_names
      all.each do |event|
        csv << event.attributes.values
      end
    end
  end
end
