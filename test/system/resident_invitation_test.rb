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
    select "#{@apartment.building.name} - Apt #{@apartment.number}", from: "Apartment"
    # Apartment already selected above
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
    # Clear any existing invitation to test the flow
    resident.update!(invited_at: nil, invitation_token: nil)

    sign_in_for_system_test(@admin_user, subdomain: "acme")

    visit resident_path(resident)

    click_button "Enviar invitación"

    assert_text "Invitación enviada exitosamente"

    resident.reload
    assert_not_nil resident.invitation_token
    assert_not_nil resident.invited_at
  end

  test "resident can accept invitation" do
    resident = residents(:invited_resident)
    resident.generate_invitation_token!

    # Set the correct subdomain for the resident's company
    Capybara.app_host = "http://acme.example.com"

    visit accept_resident_invitation_path(token: resident.invitation_token)

    assert_text "¡Bienvenido!"

    fill_in "Contraseña", with: "newpassword123"
    fill_in "Confirmar contraseña", with: "newpassword123"

    click_button "Crear mi cuenta"

    assert_text "Bienvenido a tu portal de residente"

    resident.reload
    assert_not_nil resident.invitation_accepted_at
    assert_not_nil resident.user
  end

  test "resident with invalid token cannot access invitation" do
    # Set a valid subdomain context
    Capybara.app_host = "http://acme.example.com"

    visit accept_resident_invitation_path(token: "invalid_token")

    # Invalid token redirects to sign-in page
    assert_current_path new_user_session_path
  end

  test "resident cannot accept invitation twice" do
    resident = residents(:invited_resident)
    resident.generate_invitation_token!
    resident.update!(invitation_accepted_at: Time.current)

    # Set the correct subdomain for the resident's company
    Capybara.app_host = "http://acme.example.com"

    visit accept_resident_invitation_path(token: resident.invitation_token)

    # Already accepted invitation redirects to sign-in page
    assert_current_path new_user_session_path
  end
end
