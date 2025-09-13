require "test_helper"

class ResidentConversationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @admin = users(:acme_admin)
    @resident_user = users(:acme_resident_user)
    @other_resident_user = users(:downtown_admin)

    ActsAsTenant.current_tenant = companies(:acme_properties)
  end

  test "should require authentication" do
    get resident_chat_path
    assert_redirected_to new_user_session_path
  end

  test "should not allow admin access" do
    sign_in @admin
    get resident_chat_path
    assert_redirected_to tenant_root_path
    assert_equal "Not authorized", flash[:alert]
  end

  test "resident should show their conversation" do
    sign_in @resident_user
    get resident_chat_path
    assert_response :success
    assert_assigns :conversation
    assert_assigns :message
    assert_assigns :messages
  end

  test "should create conversation if none exists" do
    # Create a new resident user without existing conversation
    new_resident = residents(:invited_resident)
    new_user = User.create!(
      email: "newresident@example.com",
      password: "password123",
      role: "resident",
      company: companies(:acme_properties),
      resident: new_resident
    )

    sign_in new_user

    assert_difference "Conversation.count", 1 do
      get resident_chat_path
    end

    assert_response :success
    conversation = assigns(:conversation)
    assert_equal new_resident, conversation.resident
    assert_equal ActsAsTenant.current_tenant, conversation.company
  end

  test "should use existing conversation if available" do
    sign_in @resident_user
    existing_conversation = conversations(:acme_conversation)

    assert_no_difference "Conversation.count" do
      get resident_chat_path
    end

    assert_response :success
    assert_equal existing_conversation, assigns(:conversation)
  end

  test "should render conversations/show template" do
    sign_in @resident_user
    get resident_chat_path
    assert_response :success
    assert_template "conversations/show"
  end

  test "should not allow access to users without resident role" do
    # Create a user without resident role
    non_resident_user = User.create!(
      email: "manager@example.com",
      password: "password123",
      role: "manager",
      company: companies(:acme_properties)
    )

    sign_in non_resident_user
    get resident_chat_path
    assert_redirected_to tenant_root_path
    assert_equal "Not authorized", flash[:alert]
  end

  private

  def assert_assigns(variable)
    assert assigns(variable), "@#{variable} should be assigned"
  end
end
