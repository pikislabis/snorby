class Opt < ActiveRecord::Base

  self.table_name = 'opt'

  self.primary_keys = :sid, :cid, :optid

  belongs_to :sensor, foreign_key: :sid, primary_key: :sid, required: true

  belongs_to :event, foreign_key: [:sid, :cid], primary_key: [:sid, :cid], required: true

  # property :sid, Integer, :key => true, :index => true, :min => 0
  #
  # property :cid, Integer, :key => true, :index => true, :min => 0
  #
  # property :optid, Integer, :key => true, :index => true, :min => 0
  #
  # property :opt_proto, Integer, :lazy => true, :min => 0
  #
  # property :opt_code, Integer, :lazy => true, :min => 0
  #
  # property :opt_len, Integer, :lazy => true, :min => 0
  #
  # property :opt_data, Text
end
