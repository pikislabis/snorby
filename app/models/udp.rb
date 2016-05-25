class Udp < ActiveRecord::Base
  self.table_name = 'udphdr'

  belongs_to :sensor, :foreign_key => [ :sid ], :primary_key => [ :sid ], :required => true

  belongs_to :event, :foreign_key => [ :sid, :cid ], :primary_key => [ :sid, :cid ], :required => true

  # property :sid, Integer, :key => true, :index => true, :min => 0
  #
  # property :cid, Integer, :key => true, :index => true, :min => 0
  #
  # property :udp_sport, Integer, :index => true, :min => 0
  #
  # property :udp_dport, Integer, :index => true, :min => 0
  #
  # property :udp_len, Integer, :lazy => true, :min => 0
  #
  # property :udp_csum, Integer, :lazy => true, :min => 0

end
