require "test_helper"

class ResidentNotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:acme_resident_user)
    sign_in_user @user, subdomain: @user.company.subdomain
  end

  test "should get index" do
    get resident_notifications_url(subdomain: @user.company.subdomain)
    assert_response :success
  end

  test "should get show" do
    @notification = notifications(:one)
    get resident_notification_url(@notification, subdomain: @user.company.subdomain)
    assert_response :success
  end
end
