class Tcp < ActiveRecord::Base
  self.table_name = 'tcphdr'

  self.primary_keys = :sid, :cid

  belongs_to :sensor, :foreign_key => [ :sid ], :primary_key => [ :sid ], :required => true

  belongs_to :event,
             :foreign_key => [ :sid, :cid ],
             :primary_key => [ :sid, :cid ],
             :required => true

  # property :sid, Integer, :key => true, :index => true, :min => 0
  #
  # property :cid, Integer, :key => true, :index => true, :min => 0
  #
  # property :tcp_sport, Integer, :index => true, :min => 0
  #
  # property :tcp_dport, Integer, :index => true, :min => 0
  #
  # property :tcp_seq, Integer, :lazy => true, :min => 0
  #
  # property :tcp_ack, Integer, :lazy => true, :min => 0
  #
  # property :tcp_off, Integer, :lazy => true, :min => 0
  #
  # property :tcp_res, Integer, :lazy => true, :min => 0
  #
  # property :tcp_flags, Integer, :lazy => true, :min => 0
  #
  # property :tcp_win, Integer, :lazy => true, :min => 0
  #
  # property :tcp_csum, Integer, :lazy => true, :min => 0
  #
  # property :tcp_urp, Integer, :lazy => true, :min => 0

end
