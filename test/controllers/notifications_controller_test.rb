require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin_user = users(:acme_admin)
    @company = companies(:acme_properties)
    @building = buildings(:acme_tower)
    @apartment = apartments(:acme_101)
    @resident = residents(:acme_resident)
  end

  test "should require authentication" do
    get notifications_path(subdomain: "acme")
    assert_redirected_to new_user_session_path
  end

  test "should require admin access" do
    resident_user = users(:acme_resident_user)
    sign_in_user(resident_user, subdomain: "acme")

    get notifications_path
    assert_redirected_to tenant_root_path
    assert_equal "Not authorized", flash[:alert]
  end

  test "admin should get index" do
    sign_in_user(@admin_user, subdomain: "acme")

    get notifications_path
    assert_response :success
    assert_select "h1", /Notifications/
  end

  test "admin should get new notification form" do
    sign_in_user(@admin_user, subdomain: "acme")

    get new_notification_path
    assert_response :success
    assert_select "form"
    assert_select "input[name='target_type'][type='radio']"
  end

  test "should create notification with building target" do
    sign_in_user(@admin_user, subdomain: "acme")

    assert_difference("Notification.count") do
      post notifications_path, params: {
        target_type: "building",
        target_id: @building.id,
        notification: {
          title: "Building Maintenance",
          message: "Maintenance scheduled for tomorrow",
          notification_type: "maintenance",
          priority: "normal"
        }
      }
    end

    notification = Notification.last
    assert_equal "Building Maintenance", notification.title
    assert_equal @building.id, notification.target_id
    assert_equal "Building", notification.target_type
    assert_redirected_to notifications_path
  end

  test "should create notification with apartment target" do
    sign_in_user(@admin_user, subdomain: "acme")

    assert_difference("Notification.count") do
      post notifications_path, params: {
        target_type: "apartment",
        target_id: @apartment.id,
        notification: {
          title: "Apartment Notice",
          message: "Individual apartment notice",
          notification_type: "general",
          priority: "urgent"
        }
      }
    end

    notification = Notification.last
    assert_equal "Apartment", notification.target_type
    assert_equal @apartment.id, notification.target_id
  end

  test "should create notification recipients for building target" do
    sign_in_user(@admin_user, subdomain: "acme")

    # Count residents who have user accounts (only they can receive notifications)
    residents_count = @building.residents.joins(:user).where.not(users: { id: nil }).count

    assert_difference("NotificationRecipient.count", residents_count) do
      post notifications_path, params: {
        target_type: "building",
        target_id: @building.id,
        notification: {
          title: "Building Notice",
          message: "Notice for all building residents",
          notification_type: "general",
          priority: "normal"
        }
      }
    end
  end

  test "should create notification recipient for apartment target" do
    sign_in_user(@admin_user, subdomain: "acme")

    residents_count = @apartment.residents.joins(:user).where.not(users: { id: nil }).count

    assert_difference("NotificationRecipient.count", residents_count) do
      post notifications_path, params: {
        target_type: "apartment",
        target_id: @apartment.id,
        notification: {
          title: "Apartment Notice",
          message: "Notice for apartment residents",
          notification_type: "general",
          priority: "normal"
        }
      }
    end
  end

  test "should not create notification with invalid params" do
    sign_in_user(@admin_user, subdomain: "acme")

    assert_no_difference("Notification.count") do
      post notifications_path, params: {
        notification: {
          title: "",
          message: "",
          target_type: "",
          target_id: nil
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "should show notification" do
    notification = Notification.create!(
      title: "Test Notification",
      message: "Test message",
      notification_type: "general",
      priority: "normal",
      sender: @admin_user,
      company: @company,
      target: @building,
      sent_at: Time.current,
      total_recipients: 0,
      read_count: 0
    )

    sign_in_user(@admin_user, subdomain: "acme")

    get notification_path(notification)
    assert_response :success
    assert_select "h1", /Test Notification/
    assert_select "p", /Test message/
  end

  test "should load apartments for building via AJAX" do
    sign_in_user(@admin_user, subdomain: "acme")

    get apartments_for_building_notifications_path(building_id: @building.id),
        xhr: true

    assert_response :success
    assert_equal "application/json", response.media_type

    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
    assert json_response.any? { |apt| apt["id"] == @apartment.id }
  end

  test "should respect tenant isolation" do
    sign_in_user(@admin_user, subdomain: "acme")

    # Try to create notification targeting different company's building
    downtown_building = buildings(:downtown_plaza)

    post notifications_path, params: {
      notification: {
        title: "Cross-tenant attempt",
        message: "Should not work",
        notification_type: "general",
        priority: "normal",
        target_type: "Building",
        target_id: downtown_building.id
      }
    }

    # Should either fail or not create notification
    if response.successful?
      notification = Notification.last
      assert_not_equal downtown_building.id, notification.target_id
    else
      assert_response :unprocessable_content
    end
  end

  private

  def sign_in_user(user, subdomain: nil)
    subdomain ||= user.company&.subdomain || "admin"
    post new_user_session_url(subdomain: subdomain),
         params: { user: { email: user.email, password: "password123" } }
  end
end
