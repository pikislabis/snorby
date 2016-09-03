require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  test 'Change company name' do
    Setting.company = 'New Snorby'
    assert_equal Setting.company, 'New Snorby'
  end

  test 'Return true when asking for company name setting' do
    assert Setting.company?
  end

  test 'Return false for undefined setting' do
    assert_not Setting.undefined_setting
  end
end
