class ReferenceSystem < ActiveRecord::Base
  self.table_name = 'reference_system'

  # property :ref_system_id, Serial, :key => true, :index => true, :min => 0
  #
  # property :ref_system_name, String

  has_many :references, foreign_key: :ref_system_id, primary_key: :ref_system_id
end
