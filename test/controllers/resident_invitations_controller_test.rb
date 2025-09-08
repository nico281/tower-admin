require "test_helper"

class ResidentInvitationsControllerTest < ActionDispatch::IntegrationTest
  test "should get accept" do
    resident = residents(:invited_resident)
    get resident_invitations_accept_url(token: resident.invitation_token)
    assert_response :success
  end
end
