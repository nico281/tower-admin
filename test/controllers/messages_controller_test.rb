require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @admin = users(:acme_admin)
    @resident_user = users(:acme_resident_user)
    @other_company_admin = users(:downtown_admin)
    @conversation = conversations(:acme_conversation)

    ActsAsTenant.current_tenant = companies(:acme_properties)
  end

  test "should require authentication" do
    post conversation_messages_path(@conversation), params: { message: { body: "Test message" } }
    assert_redirected_to new_user_session_path
  end

  test "admin should create message in conversation" do
    sign_in @admin

    assert_difference "Message.count", 1 do
      post conversation_messages_path(@conversation), params: { message: { body: "Admin message" } }
    end

    message = Message.last
    assert_equal "Admin message", message.body
    assert_equal @admin, message.sender
    assert_equal @conversation, message.conversation
    assert_equal ActsAsTenant.current_tenant, message.company

    assert_redirected_to conversation_path(@conversation)
  end

  test "resident user should create message in their conversation" do
    sign_in @resident_user

    assert_difference "Message.count", 1 do
      post conversation_messages_path(@conversation), params: { message: { body: "Resident message" } }
    end

    message = Message.last
    assert_equal "Resident message", message.body
    assert_equal @resident_user, message.sender
    assert_equal @conversation, message.conversation

    assert_redirected_to conversation_path(@conversation)
  end

  test "should not create message for non-participant" do
    sign_in @other_company_admin

    assert_no_difference "Message.count" do
      post conversation_messages_path(@conversation), params: { message: { body: "Unauthorized message" } }
    end

    assert_redirected_to tenant_root_path
    assert_equal "Not authorized", flash[:alert]
  end

  test "should handle turbo_stream format for admin" do
    sign_in @admin

    assert_difference "Message.count", 1 do
      post conversation_messages_path(@conversation),
           params: { message: { body: "Turbo stream message" } },
           as: :turbo_stream
    end

    assert_response :ok
  end

  test "should handle turbo_stream format for resident" do
    sign_in @resident_user

    assert_difference "Message.count", 1 do
      post conversation_messages_path(@conversation),
           params: { message: { body: "Resident turbo message" } },
           as: :turbo_stream
    end

    assert_response :ok
  end

  test "should not create message with empty body" do
    sign_in @admin

    assert_no_difference "Message.count" do
      post conversation_messages_path(@conversation), params: { message: { body: "" } }
    end

    assert_response :unprocessable_content
    assert_select ".error, .alert", /can't be blank/
  end

  test "should not create message without body param" do
    sign_in @admin

    assert_no_difference "Message.count" do
      post conversation_messages_path(@conversation), params: { message: {} }
    end

    assert_response :unprocessable_content
    assert_select ".error, .alert", /can't be blank/
  end

  test "should update conversation timestamp when message created" do
    sign_in @admin
    original_time = @conversation.updated_at

    travel 1.minute do
      post conversation_messages_path(@conversation), params: { message: { body: "Update timestamp test" } }
    end

    @conversation.reload
    assert @conversation.updated_at > original_time
  end
end
