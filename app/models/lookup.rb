class Lookup < ActiveRecord::Base
  # property :id, Serial
  #
  # property :title, String
  #
  # property :value, Text

  validates :title, :value, presence: true

  def build(args = {})
    args.fetch(:ip, '')
    args.fetch(:port, '')
    value.sub(/\$\{ip\}/, args[:ip].to_s).sub(/\$\{port\}/, args[:port].to_s)
  end
end
