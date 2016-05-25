class EncodingType < ActiveRecord::Base
  self.table_name = 'encoding'

  # property :encoding_type, Serial, :key => true, :index => true, :min => 0
  #
  # property :encoding_text, Text
end
