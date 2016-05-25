class Note < ActiveRecord::Base

  # property :id, Serial, :key => true
  #
  # property :sid, Integer, :index => true
  #
  # property :cid, Integer, :index => true
  #
  # property :user_id, Integer, :index => true
  #
  # property :body, Text, :lazy => true
  #
  # # timestamps :at
  # property :created_at, ZonedTime
  # property :updated_at, ZonedTime

  belongs_to :user

  belongs_to :sensor, :foreign_key => [ :sid ], :primary_key => [ :sid ], :required => true

  belongs_to :event, :foreign_key => [ :sid, :cid ], :primary_key => [ :sid, :cid ], :required => true

  validates_presence_of :body

  after_create do
    event = self.event
    user = self.user
    event.update(:notes_count => event.notes_count + 1)
    user.update(:notes_count => user.notes_count + 1)
  end

  before_destroy do
    event = self.event
    user = self.user
    event.update(:notes_count => event.notes_count - 1) if event
    user.update(:notes_count => user.notes_count - 1) if user
  end

  def in_json
    {
      :user => user.in_json,
      :body => body,
      :created_at => created_at,
      :updated_at => updated_at
    }
  end

  def html_id
    "note_#{id}"
  end

end
