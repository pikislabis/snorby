class Setting < ActiveRecord::Base
  CHECKBOXES = [
    :utc,
    :event_notifications,
    :update_notifications,
    :daily,
    :weekly,
    :monthly,
    :lookups,
    :notes,
    :packet_capture,
    :packet_capture_auto_auth,
    :autodrop,
    :geoip
  ].freeze

  validates :name, uniqueness: true

  # property :name, String, :key => true, :index => true, :required => false
  #
  # property :value, Object

  def checkbox?
    return true if CHECKBOXES.include?(name.to_sym)
    false
  end

  def self.set(name, value = nil)
    record = find_by(name: name)
    return Setting.create(name: name, value: value) if record.nil?
    record.update(value: value)
  end

  def self.find(name)
    record = find_by(name: name)
    return false if record.nil?
    return false if record.value.is_a?(Integer) && record.value.zero?
    record.value
  end

  def self.has_setting(name)
    record = find_by(name: name)
    return false if record.nil?
    return false if record.value.is_a?(Integer) && record.value.zero?
    return true unless record.value.blank?
    false
  end

  # TODO: function for change the app logo
  # def self.file(name, file)
  #   new_file_name = file.original_filename.sub(/(\w+)(?=\.)/, name.to_s)
  #   new_file_path = "#{Rails.root}/public/system/#{new_file_name}"
  #
  #   FileUtils.mv(file.tempfile.path, new_file_path)
  #   set(:logo, "#{Snorby::CONFIG[:baseuri]}/system/#{new_file_name}")
  # end

  def self.method_missing(method, *args)
    if method.to_s =~ /^(.*)=$/
      Setting.set(Regexp.last_match(1), args.first)
    elsif method.to_s =~ /^(.*)\?$/
      Setting.has_setting(Regexp.last_match(1).to_sym)
    else
      Setting.find(method.to_sym)
    end
  end
end
