require "test_helper"

class ResidentNotificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get resident_notifications_index_url
    assert_response :success
  end

  test "should get show" do
    get resident_notifications_show_url
    assert_response :success
  end
end
