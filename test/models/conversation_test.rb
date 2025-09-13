require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  setup do
    @company = companies(:acme_properties)
    @resident = residents(:acme_resident)
    @admin_user = users(:acme_admin)
    @resident_user = users(:acme_resident_user)
    @other_company_user = users(:downtown_admin)
  end

  test "should be valid with valid attributes" do
    # Use a resident that doesn't already have a conversation
    other_resident = residents(:invited_resident)
    conversation = Conversation.new(company: @company, resident: other_resident)
    assert conversation.valid?, "Conversation should be valid: #{conversation.errors.full_messages}"
  end

  test "should require company" do
    conversation = Conversation.new(resident: @resident)
    assert_not conversation.valid?
    assert_includes conversation.errors[:company], "must exist"
  end

  test "should require resident" do
    conversation = Conversation.new(company: @company)
    assert_not conversation.valid?
    assert_includes conversation.errors[:resident], "must exist"
  end

  test "should validate uniqueness of resident per company" do
    # Use a different resident since fixtures already exist
    other_resident = residents(:invited_resident)
    Conversation.create!(company: @company, resident: other_resident)
    duplicate = Conversation.new(company: @company, resident: other_resident)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:resident_id], "has already been taken"
  end

  test "should allow same resident in different companies" do
    downtown_company = companies(:downtown_management)
    other_resident = residents(:invited_resident)
    Conversation.create!(company: @company, resident: other_resident)
    different_company_conversation = Conversation.new(company: downtown_company, resident: other_resident)

    # This might fail due to tenant scoping - that's expected behavior
    # The test documents the intended behavior
    assert different_company_conversation.valid?
  end

  test "participant? should return true for company admin in same tenant" do
    conversation = conversations(:acme_conversation)
    assert conversation.participant?(@admin_user)
  end

  test "participant? should return true for resident user linked to conversation resident" do
    conversation = conversations(:acme_conversation)
    assert conversation.participant?(@resident_user)
  end

  test "participant? should return false for user from different company" do
    conversation = conversations(:acme_conversation)
    assert_not conversation.participant?(@other_company_user)
  end

  test "participant? should return false for nil user" do
    conversation = conversations(:acme_conversation)
    assert_not conversation.participant?(nil)
  end

  test "should have many messages and destroy them when conversation is destroyed" do
    # Create a new conversation to avoid fixture dependencies
    new_resident = residents(:invited_resident)
    conversation = Conversation.create!(company: @company, resident: new_resident)
    message = conversation.messages.create!(
      company: @company,
      sender: @admin_user,
      body: "Test message"
    )

    assert_difference "Message.count", -1 do
      conversation.destroy
    end
  end
end
