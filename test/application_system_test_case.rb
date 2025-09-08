require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Use rack_test driver which doesn't require browser
  driven_by :rack_test
end
