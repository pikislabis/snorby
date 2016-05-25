class Favorite < ActiveRecord::Base

  belongs_to :user

  belongs_to :event, :primary_key => [ :sid, :cid ], foreign_key: [ :sid, :cid ]

  # property :id, Serial, :index => true
  #
  # property :sid, Integer, :index => true
  #
  # property :cid, Integer, :index => true
  #
  # property :user_id, Integer, :index => true

  after_create do
    self.event.increment(:users_count) if self.event
    self.user.increment(:favorites_count) if self.user
  end

  before_destroy do
    puts 'in favorite down'
    self.event.decrement(:users_count) if self.event
    self.user.decrement(:favorites_count) if self.user
  end

end
