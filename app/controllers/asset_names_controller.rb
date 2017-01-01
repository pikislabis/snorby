class AssetNamesController < ApplicationController
  respond_to :html, :xml, :json, :js, :csv

  before_filter :require_administrative_privileges
  helper_method :sort_column, :sort_direction

  def index
    params[:sort] = sort_column
    params[:direction] = sort_direction
    @asset_names = AssetName.sorty(params)
  end

  def new_bulk_upload
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def bulk_upload
    overwrite = params.fetch(:overwrite, false)
    errors = AssetsCsvService.new(params[:csv].read, overwrite).upload

    logger.error "Errors uploading file: #{errors}" unless errors.empty?

    respond_to do |format|
      if errors.empty?
        format.html { redirect_to asset_names_path, notice: 'File Successfully Uploaded' }
        format.js
        format.json { render json: { status: 'success' } }
      else
        format.json { render json: { status: 'error', errors: errors } }
        format.html { redirect_to asset_names_path, notice: 'There was an error uploading the file' }
      end
    end
  end

  def add
    update
  end

  def update
    @asset_name = find_or_create_asset(params)

    @asset_name.attributes = { global: params[:global], name: params[:name] }

    sensors = []
    if params[:global] && params[:global] == 'true'
      AgentAssetName.where(asset_name_id: params[:id]).destroy_all if params[:id]
    elsif params[:sensors] && params[:sensors].try(:to_a)
      sensors = Sensor.where(sid: params[:sensors])
    end

    respond_to do |format|
      if @asset_name.save_with_sensors(sensors)
        format.html { render layout: true }
        format.js
        format.json { render json: { asset_name: @asset_name.detailed_json } }
      else
        format.json { render json: { errors: @asset_name.errors } }
      end
    end
  end

  def remove
    @asset_name = AssetName.find_by_id(params[:id])
    AgentAssetName.where(asset_name_id: params[:id]).destroy_all
    @asset_name.destroy! if @asset_name
    render layout: false, json: @asset_name
  end

  private

  def find_or_create_asset(params)
    ip = IPAddr.new(params[:ip_address], Socket::AF_INET) if params[:ip_address]

    if params[:id]
      AssetName.create_with(ip_address: ip, name: params[:name],
                            global: params[:global])
               .find_or_create_by(id: params[:id])
    else
      AssetName.find_or_create_by(ip_address: ip, name: params[:name],
                                  global: params[:global])
    end
  end

  def sort_column
    if params.key?(:sort) && (Event::SORT.key?(params[:sort].to_sym) || params[:sort].to_sym == :signature)
      params[:sort].to_sym
    else
      :ip_address
    end
  end

  def sort_direction
    %w(asc desc).include?(params[:direction].to_s) ? params[:direction].to_sym : :desc
  end
end
