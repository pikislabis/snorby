class NotificationsController < ApplicationController
  def index
    @notifications = Notification.all
                                 .order(created_at: :desc)
                                 .paginate(page: params[:page],
                                           per_page: @current_user.per_page_count)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @notifications }
    end
  end

  def show
    @notification = Notification.find(params[:id])

    respond_to do |format|
      format.html { render layout: false }
      format.xml  { render xml: @notification }
    end
  end

  def new
    event = Event.find_by(sid: params[:sid], cid: params[:cid])
    @notification = Notification.new(sig_id: event.signature.sig_id,
                                     ip_src: event.ip.ip_src.to_s,
                                     ip_dst: event.ip.ip_dst.to_s)
    render layout: false
  end

  def edit
    @notification = Notification.find(params[:id])
    render layout: false
  end

  def create
    @notification = Notification.create(params[:notification])

    if params[:use_ip_src]
      @notification.ip_src = params[:notification][:ip_src]
    else
      @notification.ip_src = nil
    end

    if params[:use_ip_dst]
      @notification.ip_dst = params[:notification][:ip_dst]
    else
      @notification.ip_dst = nil
    end

    @notification.user = @current_user

    @notification.save

    respond_to do |format|
      format.html { render layout: false }
      format.js
    end
  end

  def update
    @notification = Notification.find(params[:id])

    respond_to do |format|
      if @notification.update(params[:notification])
        format.html { redirect_to(@notification, notice: 'Notification was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render action 'edit' }
        format.xml  { render xml: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy

    respond_to do |format|
      format.html { redirect_to(notifications_url, notice: 'Notification removed successfully.') }
      format.xml  { head :ok }
    end
  end
end
