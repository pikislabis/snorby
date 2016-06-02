class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :event, primary_key: [:sid, :cid], foreign_key: [:sid, :cid]

  # property :id, Serial, :index => true
  #
  # property :sid, Integer, :index => true
  #
  # property :cid, Integer, :index => true
  #
  # property :user_id, Integer, :index => true

  after_create :increment_counts
  before_destroy :decrement_counts

  private

  def increment_counts
    user.increment!(:favorites_count) if user
    event.increment!(:users_count) if event
  end

  def decrement_counts
    event.decrement!(:users_count) if event
    user.decrement!(:favorites_count) if user
  end
end
