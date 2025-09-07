require "application_system_test_case"

class ResidentDashboardTest < ApplicationSystemTestCase
  def setup
    @resident_user = users(:acme_resident_user)
    @resident = residents(:acme_resident)
    @building = buildings(:acme_tower)
    @apartment = apartments(:acme_101)
  end

  test "resident can access their dashboard" do
    sign_in_for_system_test(@resident_user, subdomain: "acme")

    visit tenant_root_path

    assert_text "Welcome, #{@resident.display_name}"
    assert_text @building.name
    assert_text "Apartment #{@apartment.number}"
  end

  test "resident dashboard shows building information" do
    sign_in_for_system_test(@resident_user, subdomain: "acme")

    visit tenant_root_path

    assert_text @building.name
    assert_text @building.address
    assert_text "Floor #{@apartment.floor}"
    assert_text "#{@apartment.bedrooms} bedrooms"
    assert_text "#{@apartment.bathrooms} bathrooms"
  end

  test "resident dashboard shows payment information" do
    sign_in_for_system_test(@resident_user, subdomain: "acme")

    visit tenant_root_path

    assert_text "Recent Payments"
    assert_text "Pending Payments"
  end

  test "resident can view their notifications" do
    sign_in_for_system_test(@resident_user, subdomain: "acme")

    click_link "My Notifications"

    assert_current_path resident_notifications_path
    assert_text "Your Notifications"
  end

  test "resident can mark notification as read" do
    # Create a notification for testing
    notification = Notification.create!(
      title: "Test Notification",
      message: "This is a test notification",
      notification_type: "general",
      priority: "normal",
      sender: users(:acme_admin),
      company: companies(:acme_properties),
      target_type: "Building",
      target_id: @building.id
    )

    recipient = NotificationRecipient.create!(
      notification: notification,
      resident: @resident
    )

    sign_in_for_system_test(@resident_user, subdomain: "acme")

    visit resident_notifications_path

    assert_text "Test Notification"

    click_link "Test Notification"

    assert_text "This is a test notification"

    click_button "Mark as Read"

    assert_text "Notification marked as read"

    recipient.reload
    assert_not_nil recipient.read_at
  end

  test "resident cannot access admin functions" do
    sign_in_for_system_test(@resident_user, subdomain: "acme")

    visit buildings_path

    assert_text "Not authorized"
    assert_current_path tenant_root_path
  end
end
