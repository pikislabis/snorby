class AssetName < ActiveRecord::Base
  validate :validate_asset_name

  # property :id, Serial, :key => true
  #
  # property :ip_address, NumericIPAddr, :index => true, :min => 0,
  #   :required => true, :default => 0
  #
  # property :name, String, :length => 1024, :required => true
  #
  # property :global, Boolean, :default => true

  has_many :agent_asset_names, foreign_key: :asset_name_id, dependent: :destroy
  has_many :sensors, through: :agent_asset_names

  def ip_address
    IPAddr.new(super, Socket::AF_INET)
  end

  def save_with_sensors(updated_sensors)
    return false unless save!

    agent_asset_names.delete_all

    if updated_sensors && !updated_sensors.empty?
      updated_sensors.each do |sensor|
        AgentAssetName.create(sensor_sid: sensor.sid, asset_name_id: id)
      end
    end

    true
  end

  def validate_asset_name
    if !global && sensors.empty?
      return [false, 'Non-global asset_names must have at least one sensor.']
    end

    true
  end

  def agent_ids_string
    sensors.map(&:sid).join(',')
  end

  def applies_to
    return 'All Agents' if global

    "#{sensors.count} Agents"
  end

  def detailed_json
    {
      id: id,
      name: name,
      global: global,
      ip_address: ip_address.to_s,
      sensors: sensors.map(&:id)
    }
  end

  def self.sorty(params = {})
    sort = params[:sort]
    direction = params[:direction]

    page = {
      page: (params[:page] || 1).to_i,
      per_page: User.current_user.per_page_count
    }

    paginate(page).order(sort.to_sym => direction)
  end
end
