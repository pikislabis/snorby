class User < ActiveRecord::Base
  cattr_accessor :current_user, :snorby_url, :current_json

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  if Snorby::CONFIG[:authentication_mode] == 'cas'
    devise :cas_authenticatable, :registerable, :trackable
    property :email, String, required: true, unique: true
  else
    devise :database_authenticatable, :registerable, :recoverable,
           :rememberable, :trackable, :validatable
  end

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  # property :favorites_count, Integer, :index => true, :default => 0
  # property :accept_notes, Integer, :default => 1
  #property :notes_count, Integer, :index => true, :default => 0
  # Primary key of the user
  #property :id, Serial, :key => true, :index => true
  # property :per_page_count, Integer, :index => true, :default => 45
  # Full name of the user
  #property :name, String, :lazy => true
  # Define created_at and updated_at timestamps
  #timestamps :at
  #property :created_at, ZonedTime
  #property :updated_at, ZonedTime
  #property :last_sign_in_at, ZonedTime

  # for sure with socket.io sessions
  #property :online, Boolean, :default => false
  #property :last_daily_report_at, ZonedTime, :default => Time.zone.now
  #property :last_weekly_report_at, Integer, :default => Time.zone.now.strftime("%Y%W")
  #property :last_monthly_report_at, Integer, :default => Time.zone.now.strftime("%Y%m")
  #property :last_email_report_at, ZonedTime
  #property :email_reports, Boolean, :default => false


  # The timezone the user lives in
  #property :timezone, String, :default => 'UTC', :lazy => true

  # Define if the user has administrative privileges
  #property :admin, Boolean, :default => false

  # Define if the user has been enabled/disabled
  #property :enabled, Boolean, :default => true

  # Define if get avatar from gravatar.com or not
  #property :gravatar, Boolean, :default => true


  # Email of the user
  #
  # property :email, String, :required => true, :unique => true
  #
  # property :avatar_file_name, String
  #
  # property :avatar_content_type, String
  #
  # property :avatar_file_size, Integer
  #
  # property :avatar_updated_at, DateTime

  # property :avatar, Text, :default => false
  # has_attached_file :avatar,
  # :styles => {
    # :large => "500x500>",
    # :medium => "300x300>",
    # :small => "100x100#"
  # }, :default_url => '/images/default_avatar.png', :processors => [:cropper],
    # :whiny => false

  # validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/gif', 'image/png', 'image/pjpeg', 'image/x-png'],
  # :message => 'Uploaded file is not an image',
  # :if => Proc.new { |profile| profile.avatar.file? }

  has_many :notifications, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :saved_searches, dependent: :destroy
  has_many :events
  has_many :events, through: :favorites

  #
  # Converts the user to a String.
  #
  # @return [String]
  #   The name of the user.
  #
  def to_s
    name.to_s
  end

  def avatar
    default_url = File.join(::User.snorby_url, "#{Snorby::CONFIG[:baseuri]}/images/default_avatar.png")
    return default_url unless gravatar

    email_address = email.downcase

    # create the md5 hash
    hash = Digest::MD5.hexdigest(email_address)
    "https://gravatar.com/avatar/#{hash}.png?s=256&d=#{CGI.escape(default_url)}"
  end

  def in_json
    # create the md5 hash
    hash = Digest::MD5.hexdigest(email)
    # "https://gravatar.com/avatar/#{hash}.png?s=256&d=#{CGI.escape(default_url)}"
    data = attributes
    data[:gravatar_hash] = hash
    data[:classify_count] = classify_count
    data
  end

  def classify_count
    Event.where(user_id: id).count
  end

  def send_daily_report
    ReportMailer.daily_report("#{name} <#{email}>", timezone).deliver_now
  end

  def send_weekly_report
    ReportMailer.weekly_report("#{name} <#{email}>", timezone).deliver_now
  end

  def send_monthly_report
    ReportMailer.monthly_report("#{name} <#{email}>", timezone).deliver_now
  end

  def send_update_report(data)
    ReportMailer.update_report("#{name} <#{email}>", data, timezone).deliver_now
  end

  def accepts_note_notifications?(event = false)
    return true if accept_notes == 1
    if accept_notes == 3
      return false unless event
      return true if added_notes_for_event?(event)
    end

    false
  end

  def added_notes_for_event?(event)
    Note.where(sid: event.sid, cid: event.cid, user: self).any?
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end

  def reprocess_avatar
    avatar.reprocess! if cropping?
  end
end
