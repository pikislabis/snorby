class EventsController < ApplicationController
  respond_to :html, :xml, :json, :js, :csv

  helper_method :sort_column, :sort_direction

  def index
    params[:sort] = sort_column
    params[:direction] = sort_direction

    @events = Event.sorty(params)
    @classifications ||= Classification.all

    respond_event
  end

  def sessions
    @session_view = true

    params[:sort] = sort_column
    params[:direction] = sort_direction

    sql = %{
      select e.sid, e.cid, e.signature,
      e.classification_id, e.users_count,
      e.notes_count, e.timestamp, e.user_id,
      a.number_of_events from aggregated_events a
      inner join event e on a.event_id = e.id
    }

    sort = if [:sid,:signature,:timestamp].include?(params[:sort])
             "e.#{params[:sort]}"
           elsif params[:sort] == :sig_priority
             sql += 'inner join signature s on e.signature = s.sig_id '
             "s.#{params[:sort]}"
           else
             "a.#{params[:sort]}"
           end

    sql += "order by #{sort} #{params[:direction]}"

    @events = Event.sorty(params, [sql], "select count(*) from aggregated_events;")

    @classifications ||= Classification.all

    respond_event
  end

  def queue
    params[:sort] = sort_column
    params[:direction] = sort_direction
    params[:classification_all] = true
    params[:user_events] = true

    @events ||=
      current_user.events.paginate(
        page: (params[:page] || 1).to_i,
        per_page: @current_user.per_page_count
      )

    @classifications ||= Classification.all

    respond_event
  end

  def request_packet_capture
    @event = Event.find_by(sid: params['sid'], cid: params['cid'])
    @packet = @event.packet_capture(params)
    respond_to do |format|
      format.html { render layout: false }
      format.js
    end
  end

  def rule
    @event = Event.find_by(sid: params['sid'], cid: params['cid'])
    @event.rule ? @rule = @event.rule : @rule = 'No rule found for this event.'

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def show
    @session_view = true if params.key?(:sessions)

    @event = Event.find_by(sid: params['sid'], cid: params['cid'])
    @lookups ||= Lookup.all

    @notes = @event.notes.all.paginate(page: (params[:page] || 1).to_i,
                                       per_page: 5).order(id: :desc)

    respond_to do |format|
      format.html { render layout: false }
      format.js

      format.pdf do
        render pdf: "Event:#{@event.id}",
               template: 'events/show.pdf.erb',
               layout: 'pdf.html.erb', stylesheets: ['pdf']
      end

      format.xml { render xml: @event.in_xml }
      format.csv do
        render text: ActionController::Base.helpers.sanitize(@event.to_csv)
      end
      format.json do
        render json: { event: @event.in_json, notes: @notes.map(&:in_json) }
      end
    end
  end

  def view
    @events = Event.where(sid: params['sid'], cid: params['cid'])
                   .paginate(page: (params[:page] || 1).to_i,
                             per_page: @current_user.per_page_count)
                   .order(timestamp: :desc)

    @classifications ||= Classification.all
  end

  def create_email
    @event = Event.find_by(sid: params[:sid], cid: params[:cid])
    render layout: false
  end

  def email
    Delayed::Job.enqueue(
      Snorby::Jobs::EventMailerJob.new(params[:sid], params[:cid],
                                       params[:email])
    )

    respond_to do |format|
      format.html { render layout: false }
      format.js
    end
  end

  def create_mass_action
    @event = Event.find_by(sid: params[:sid], cid: params[:cid])
    render layout: false
  end

  def mass_action
    options = {}

    options[:sid] = params[:sensor_ids] if params.key?(:sensor_ids)
    options[:classification_id] = nil unless params[:reclassify]
    options[:signature] = params[:sig_id] if params[:use_sig_id]

    if params[:use_ip_src]
      options[:iphdr] ||= {}
      options[:iphdr][:ip_src] = params[:ip_src]
    end

    if params[:use_ip_dst]
      options[:iphdr] ||= {}
      options[:iphdr][:ip_dst] = params[:ip_dst]
    end

    if options.empty?
      render js: "flash_message.push({type: 'error', message: 'Sorry, \
                  Insufficient classification parameters submitted...'});flash();"
    else

      ids = Event.includes(:ip).where(options).map { |x| "#{x.sid}-#{x.cid}" }.join(',')

      if params[:jobqueue]
        Delayed::Job.enqueue(
          Snorby::Jobs::MassClassification.new(
            ids, params[:classification_id], User.current_user.id
          )
        )
      else
        Event.update_classification(ids, params[:classification_id], User.current_user.id)
      end

      respond_to do |format|
        format.html { render layout: false }
        format.js
      end
    end
  end

  def export
    @events = Event.find_by_ids(params[:events])

    respond_to do |format|
      format.json { render json: @events }
      format.xml { render xml: @events }
      format.csv { render json: @events.to_csv }
    end
  end

  def history
    @events = Event.all(user_id: @current_user.id)
                   .page(params[:page].to_i,
                         per_page: @current_user.per_page_count,
                         order: [:timestamp.desc])
    @classifications ||= Classification.all
  end

  def classify
    if params[:events]
      Event.update_classification(params[:events],
                                  params[:classification].to_i,
                                  User.current_user.id)
    end

    respond_to do |format|
      format.html { render layout: false, status: 200 }
      format.json { render json: { status: 'success' } }
    end
  end

  def classify_sessions
    if params[:events]
      Event.update_classification_by_session(params[:events],
                                             params[:classification].to_i,
                                             User.current_user.id)
    end

    respond_to do |format|
      format.html { render layout: false, status: 200 }
      format.json { render json: { status: 'success' } }
    end
  end

  def mass_create_favorite
    @events ||= Event.find_by_ids(params[:events])
    @events.each { |event| event.create_favorite unless favorite? }
    render json: {}
  end

  def mass_destroy_favorite
    @events ||= Event.find_by_ids(params[:events])
    @events.each { |event| event.destroy_favorite if favorite? }
    render json: {}
  end

  def last
    render json: { time: Event.last_event_timestamp }
  end

  def since
    @events = Event.to_json_since(params[:timestamp])
    render json: @events.to_json
  end

  def favorite
    @event = Event.find_by(sid: params[:sid], cid: params[:cid])
    @event.toggle_favorite
    render json: { favorite: @event.favorite? }
  end

  def lookup
    if Setting.lookups?
      @lookup = Snorby::Lookup.new(params[:address])
      render layout: false
    else
      render text: '<div id="note-box">This feature has be disabled</div>'.html_safe,
             notice: 'This feature has be disabled'
    end
  end

  def activity
    @user = User.find(params[:user_id])
    @user = @current_user unless @user

    @events = @user.events.page(params[:page].to_i,
                                per_page: @current_user.per_page_count,
                                order: [:timestamp.desc])

    @classifications ||= Classification.all
  end

  def hotkey
    @classifications ||= Classification.all
    respond_to do |format|
      format.html { render layout: false }
      format.js
    end
  end

  def packet_capture
    @event = Event.find_by(sid: params[:sid], cid: params[:cid])
    render layout: false
  end

  private

  def sort_column
    if params.key?(:sort)
      return params[:sort].to_sym if Event::SORT.key?(params[:sort].to_sym) ||
                                     [:signature].include?(params[:sort].to_sym)
    end

    :timestamp
  end

  def sort_direction
    %w(asc desc).include?(params[:direction].to_s) ? params[:direction].to_sym : :desc
  end

  def respond_event
    respond_to do |format|
      format.html { render layout: true }
      format.js
      format.json do
        render json: {
          events: @events.map(&:detailed_json),
          classifications: @classifications,
          pagination: {
            total: @events.pager.total,
            per_page: @events.pager.per_page,
            current_page: @events.pager.current_page,
            previous_page: @events.pager.previous_page,
            next_page: @events.pager.next_page,
            total_pages: @events.pager.total_pages
          }
        }
      end
    end
  end
end
