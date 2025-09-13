require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @admin = users(:acme_admin)
    @resident_user = users(:acme_resident_user)
    @other_company_admin = users(:downtown_admin)
    @conversation = conversations(:acme_conversation)

    ActsAsTenant.current_tenant = companies(:acme_properties)
  end

  test "should require authentication for index" do
    get conversations_path
    assert_redirected_to new_user_session_path
  end

  test "admin should get index" do
    sign_in @admin
    get conversations_path
    assert_response :success
    assert_select "h1", /Conversations/
  end

  test "resident should not access index" do
    sign_in @resident_user
    get conversations_path
    assert_redirected_to tenant_root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should require authentication for show" do
    get conversation_path(@conversation)
    assert_redirected_to new_user_session_path
  end

  test "admin should show conversation" do
    sign_in @admin
    get conversation_path(@conversation)
    assert_response :success
    assert_assigns :conversation
    assert_assigns :message
    assert_assigns :messages
  end

  test "resident user should show their conversation" do
    sign_in @resident_user
    get conversation_path(@conversation)
    assert_response :success
    assert_assigns :conversation
    assert_assigns :message
    assert_assigns :messages
  end

  test "should not show conversation to non-participant" do
    sign_in @other_company_admin
    get conversation_path(@conversation)
    assert_redirected_to tenant_root_path
    assert_equal "Not authorized", flash[:alert]
  end

  test "should require authentication for ensure_for_resident" do
    resident = residents(:acme_resident)
    post open_chat_resident_path(resident)
    assert_redirected_to new_user_session_path
  end

  test "admin should create conversation for resident" do
    sign_in @admin
    resident = residents(:downtown_resident)

    assert_difference "Conversation.count", 1 do
      post open_chat_resident_path(resident)
    end

    conversation = Conversation.find_by(resident: resident, company: ActsAsTenant.current_tenant)
    assert_redirected_to conversation_path(conversation)
  end

  test "admin should redirect to existing conversation for resident" do
    sign_in @admin
    resident = residents(:acme_resident)
    existing_conversation = conversations(:acme_conversation)

    assert_no_difference "Conversation.count" do
      post open_chat_resident_path(resident)
    end

    assert_redirected_to conversation_path(existing_conversation)
  end

  test "resident should not access ensure_for_resident" do
    sign_in @resident_user
    resident = residents(:acme_resident)
    post open_chat_resident_path(resident)
    assert_redirected_to tenant_root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  private

  def assert_assigns(variable)
    assert assigns(variable), "@#{variable} should be assigned"
  end
end
