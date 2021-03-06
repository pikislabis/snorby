class PageController < ApplicationController

  helper_method :sort_column, :sort_direction, :sort_page
  include Snorby::Jobs::CacheHelper

  def dashboard
    @now = Time.now

    @range = params[:range].blank? ? 'last_24' : params[:range]

    if @range.to_sym == :custom
      begin
        @custom_start = Time.zone.parse(params[:start]).utc.strftime('%Y-%m-%d %H:%M:%S')
        @custom_end = Time.zone.parse(params[:end]).utc.strftime('%Y-%m-%d %H:%M:%S')
      rescue => e
      end
    end

    set_defaults

    @src_metrics = @caches.src_metrics
    @dst_metrics = @caches.dst_metrics

    @tcp = @caches.protocol_count(:tcp, @range.to_sym)
    @udp = @caches.protocol_count(:udp, @range.to_sym)
    @icmp = @caches.protocol_count(:icmp, @range.to_sym)

    @high = @caches.severity_count(:high, @range.to_sym)
    @medium = @caches.severity_count(:medium, @range.to_sym)
    @low = @caches.severity_count(:low, @range.to_sym)

    @sensor_metrics = @caches.sensor_metrics(@range.to_sym)

    @signature_metrics = @caches.signature_metrics

    @event_count = @caches.map(&:event_count).sum

    @axis = if @sensor_metrics.last
              @sensor_metrics.last[:range].join(',')
            else
              ''
            end

    @classifications = Classification.all.order(events_count: :desc)
    @sensors = Sensor.all.limit(5).order(events_count: :desc)
    @favers = User.all.limit(5).order(favorites_count: :desc)

    @last_cache = @caches.cache_time

    signatures = latest_five_distinct_signatures

    @recent_events = []
    signatures.each { |s| @recent_events << Event.where(signature: s).last }

    respond_to do |format|
      format.html # { render :template => 'page/dashboard.pdf.erb', :layout => 'pdf.html.erb' }
      format.js
      format.pdf do
        render pdf: "Snorby Report - #{@start_time.strftime('%A-%B-%d-%Y-%I-%M-%p')} - #{@end_time.strftime('%A-%B-%d-%Y-%I-%M-%p')}", :template => "page/dashboard.pdf.erb", :layout => 'pdf.html.erb', :stylesheets => ["pdf"]
      end
    end
  end

  def search
    @json = Snorby::Search.json
  end

  def search_json
    render json: Snorby::Search.json
  end

  def force_cache
    DelayedJob.force_sensor_cache
    render json: {
      caching: DelayedJob.caching?,
      problems: Snorby::Worker.problems?,
      running: Snorby::Worker.running?,
      daily_cache: DelayedJob.daily_cache?,
      sensor_cache: DelayedJob.sensor_cache?
    }
  end

  def cache_status
    render json: {
      caching: DelayedJob.caching?,
      problems: Snorby::Worker.problems?,
      running: Snorby::Worker.running?,
      daily_cache: DelayedJob.daily_cache?,
      sensor_cache: DelayedJob.sensor_cache?
    }
  end

  def results
    if params.key?(:search) && !params[:search].blank?

      if params[:search].is_a?(String)
        @value ||= JSON.parse(params[:search])
        params[:search] = @value
      end

      enabled_count = 0
      params[:search].each do |item|
        x = item.last
        enabled = (x['enabled'] || x[:enabled]).to_s

        if !enabled.blank?
          enabled_count += 1 if enabled.to_s == 'true'
        else
          enabled_count += 1
        end
      end

      if enabled_count == 0
        redirect_to :back, flash: { error: 'There was a problem parsing the search rules.' }

      else
        @search_object ||= params[:search_id] if params[:search_id]

        params[:sort] = sort_column
        params[:direction] = sort_direction

        params[:classification_all] = true

        @search = (params.key?(:authenticity_token) ? true : false)

        @params = params.to_json

        @events = Event.sorty(params)

        @classifications ||= Classification.all
      end

    else
      redirect_to :back, flash: {
        error: 'There was a problem parsing the search rules.'
      }
    end

  rescue ActionController::RedirectBackError
    redirect_to search_path, flash: {
      error: 'There was a problem parsing the search rules.'
    }
  end

  private

  def set_defaults
    @now = Time.zone.now

    case @range.to_sym
    when :custom
      @caches = Cache.where('ran_at >= ? AND ran_at <= ?', @custom_start, @custom_end)
      @start_time = Time.zone.parse(@custom_start).beginning_of_day
      @end_time = Time.zone.parse(@custom_end).end_of_day
    when :last_24
      @start_time = @now.yesterday
      @end_time = @now

      # Fix This
      # @start_time = @now.yesterday.beginning_of_day
      # @end_time = @now.end_of_day

      @caches = Cache.last_24(@start_time, @end_time)

    when :today
      @caches = Cache.today
      @start_time = @now.beginning_of_day
      @end_time = @now.end_of_day

    when :yesterday
      @caches = Cache.yesterday
      @start_time = (@now - 1.day).beginning_of_day
      @end_time = (@now - 1.day).end_of_day

    when :week
      @caches = DailyCache.this_week
      @start_time = @now.beginning_of_week
      @end_time = @now.end_of_week

    when :last_week
      @caches = DailyCache.last_week
      @start_time = (@now - 1.week).beginning_of_week
      @end_time = (@now - 1.week).end_of_week

    when :month
      @caches = DailyCache.this_month
      @start_time = @now.beginning_of_month
      @end_time = @now.end_of_month

    when :last_month
      @caches = DailyCache.last_month
      @start_time = (@now - 1.months).beginning_of_month
      @end_time = (@now - 1.months).end_of_month

    when :quarter
      @caches = DailyCache.this_quarter
      @start_time = @now.beginning_of_quarter
      @end_time = @now.end_of_quarter

    when :year
      @caches = DailyCache.this_year
      @start_time = @now.beginning_of_year
      @end_time = @now.end_of_year

    else
      @caches = Cache.today
      @start_time = @now.beginning_of_day
      @end_time = @now.end_of_day
    end
  end

  def sort_column
    return :timestamp unless params.key?(:sort)
    return params[:sort].to_sym if Event::SORT.key?(params[:sort].to_sym)
    :timestamp
  end

  def sort_direction
    %w(asc desc).include?(params[:direction].to_s) ? params[:direction].to_sym : :desc
  end

  def sort_page
    params[:page].to_i
  end
end
