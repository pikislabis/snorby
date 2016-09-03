class Signature < ActiveRecord::Base

  self.table_name = 'signature'

  belongs_to :category, foreign_key: :sig_class_id, primary_key: :sig_class_id, required: true

  has_many :events, foreign_key: :sig_id, primary_key: :sig_id, dependent: :destroy

  has_many :notifications, primary_key: :sig_id, foreign_key: :sig_id

  belongs_to :severity, primary_key: :sig_priority, foreign_key: :sig_id

  has_many :sig_references, foreign_key: :sig_id, primary_key: :sig_id

  # property :sig_id, Serial, :key => true, :index => true, :min => 0
  #
  # property :sig_class_id, Integer, :index => true, :min => 0
  #
  # property :sig_name, Text
  #
  # property :sig_priority, Integer, :index => true, :min => 0
  #
  # property :sig_rev, Integer, :lazy => true, :min => 0
  #
  # property :sig_sid, Integer, :lazy => true, :min => 0
  #
  # property :sig_gid, Integer, :lazy => true, :min => 0
  #
  # property :events_count, Integer, :index => true, :default => 0, :min => 0

  def refs
    sig_references
  end

  def severity_id
    sig_priority
  end

  def name
    sig_name
  end

  #
  #
  #
  def event_percentage(in_words = false, count = Event.count)
    if in_words
      "#{events_count}/#{count}"
    else
      return 0 if count.zero?
      format('%.2f', ((events_count.to_f / count.to_f) * 100).round(2))
    end
  rescue FloatDomainError
    0
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
