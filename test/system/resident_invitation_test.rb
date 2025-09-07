require "application_system_test_case"

class ResidentInvitationTest < ApplicationSystemTestCase
  def setup
    @admin_user = users(:acme_admin)
    @company = companies(:acme_properties)
    @building = buildings(:acme_tower)
    @apartment = apartments(:acme_101)
  end

  test "admin can invite a new resident" do
    sign_in_for_system_test(@admin_user, subdomain: "acme")

    visit new_resident_path

    fill_in "First name", with: "Jane"
    fill_in "Last name", with: "Smith"
    fill_in "Email", with: "jane.smith@example.com"
    fill_in "Phone", with: "+1-555-999-8888"
    select @apartment.building.name, from: "Building"
    select @apartment.number, from: "Apartment"
    fill_in "Emergency contact", with: "John Smith - +1-555-888-7777"

    click_button "Create Resident"

    assert_text "Resident was successfully created"

    # Check that resident was created
    resident = Resident.find_by(email: "jane.smith@example.com")
    assert_not_nil resident
    assert_equal "Jane", resident.first_name
    assert_equal "Smith", resident.last_name
  end

  test "admin can send invitation to resident" do
    resident = residents(:invited_resident)

    sign_in_for_system_test(@admin_user, subdomain: "acme")

    visit resident_path(resident)

    click_button "Send Invitation"

    assert_text "Invitation sent successfully"

    resident.reload
    assert_not_nil resident.invitation_token
    assert_not_nil resident.invited_at
  end

  test "resident can accept invitation" do
    resident = residents(:invited_resident)
    resident.generate_invitation_token!

    visit accept_resident_invitation_path(token: resident.invitation_token)

    assert_text "Create Your Account"

    fill_in "Password", with: "newpassword123"
    fill_in "Password confirmation", with: "newpassword123"

    click_button "Create Account"

    assert_text "Welcome! Your account has been created."

    resident.reload
    assert_not_nil resident.invitation_accepted_at
    assert_not_nil resident.user
  end

  test "resident with invalid token cannot access invitation" do
    visit accept_resident_invitation_path(token: "invalid_token")

    assert_text "Invalid or expired invitation"
  end

  test "resident cannot accept invitation twice" do
    resident = residents(:invited_resident)
    resident.generate_invitation_token!
    resident.update!(invitation_accepted_at: Time.current)

    visit accept_resident_invitation_path(token: resident.invitation_token)

    assert_text "Invitation has already been accepted"
  end
end
