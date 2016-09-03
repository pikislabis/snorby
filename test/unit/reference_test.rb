require 'test_helper'

class ReferenceTest < ActiveSupport::TestCase
  context 'References' do
    setup do
      @reference_one = references(:one)
      @reference_two = references(:two)
      @reference_system = @reference_one.reference_system
    end

    should 'return the value' do
      assert_equal @reference_one.value, @reference_one.ref_tag
    end

    should 'return type' do
      assert_equal @reference_one.type, @reference_system.ref_system_name
    end

    should 'return N/A without reference system' do
      assert_equal @reference_two.type, 'N/A'
    end
  end
end
