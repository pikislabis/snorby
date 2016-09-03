require 'test_helper'

class SignatureTest < ActiveSupport::TestCase
  context 'A signature' do
    setup do
      @signature = Signature.new
    end

    should 'be 0 for event percentage if there is no events' do
      assert_equal @signature.event_percentage(false, 0), 0
    end
  end
end
