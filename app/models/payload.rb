require 'snorby/payload'

class Payload < ActiveRecord::Base

  self.table_name = 'data'

  self.primary_keys = :sid, :cid

  # property :sid, Integer, :key => true, :index => true, :min => 0
  #
  # property :cid, Integer, :key => true, :index => true, :min => 0
  #
  # property :data_payload, Text

  belongs_to :sensor, foreign_key: :sid, primary_key: :sid, required: true

  belongs_to :event, foreign_key: [:sid, :cid], primary_key: [:sid, :cid], required: true

  def to_s
    Snorby::Payload.new([data_payload].pack('H*'), :width => 26).to_s
  end

  def to_html
    return Snorby::Payload.new([data_payload].pack('H*'), :width => 26, :html => true).to_s.html_safe if data_payload
    nil
  end

  def to_ascii
    return Snorby::Payload.new([data_payload].pack('H*'), :width => 26, :ascii => true, :new_lines => true).to_s.html_safe if data_payload
    nil
  end

end
