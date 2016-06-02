class Icmp < ActiveRecord::Base
  self.table_name = 'icmphdr'

  self.primary_keys = :sid, :cid

  belongs_to :sensor, foreign_key: :sid, primary_key: :sid,
                      required: true

  belongs_to :event, foreign_key: [:sid, :cid], primary_key: [:sid, :cid],
                     required: true

  # property :sid, Integer, :key => true, :index => true, :min => 0
  #
  # property :cid, Integer, :key => true, :index => true, :min => 0
  #
  # property :icmp_type, Integer, :lazy => true, :min => 0
  #
  # property :icmp_code, Integer, :lazy => true, :min => 0
  #
  # property :icmp_csum, Integer, :lazy => true, :min => 0
  #
  # property :icmp_id, Integer, :lazy => true, :min => 0
  #
  # property :icmp_seq, Integer, :lazy => true, :min => 0

end
