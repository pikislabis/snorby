class SigReference < ActiveRecord::Base
  self.table_name = 'sig_reference'

  self.primary_keys = :sig_id, :ref_seq

  # property :sig_id, Integer, :key => true, :index => true, :min => 0
  #
  # property :ref_seq, Integer, :key => true, :index => true, :min => 0
  #
  # property :ref_id, Integer, :min => 0

  has_one :reference, :foreign_key => :ref_id, :primary_key => [:ref_id]
end
