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

  has_many :agent_asset_names

  has_many :sensors, through: :agent_asset_names

  def save_with_sensors(updated_sensors)
    return false unless save!

    agent_asset_names.destroy!

    if updated_sensors && !updated_sensors.empty?
      updated_sensors.each do |sensor|
        AgentAssetName.create(sensor_sid: sensor.sid, asset_name_id: id).save!
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
    sensors.map(&:sid).join(",")
  end

  def applies_to
    if self.global
      return 'All Agents'
    end

    return "#{sensors.count} Agents"
  end

  def detailed_json

    return {
      :id => self.id,
      :name => self.name,
      :global => self.global,
      :ip_address => self.ip_address.to_s,
      :sensors => self.sensors.map{|sensor| sensor.sid}
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
