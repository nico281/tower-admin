require "test_helper"

class ResidentInvitationsControllerTest < ActionDispatch::IntegrationTest
  test "should get accept" do
    get resident_invitations_accept_url
    assert_response :success
  end
end
