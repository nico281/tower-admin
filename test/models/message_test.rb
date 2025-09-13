require "test_helper"

class MessageTest < ActiveSupport::TestCase
  setup do
    @company = companies(:acme_properties)
    @conversation = conversations(:acme_conversation)
    @sender = users(:acme_admin)
  end

  test "should be valid with valid attributes" do
    message = Message.new(
      company: @company,
      conversation: @conversation,
      sender: @sender,
      body: "Hello, this is a test message."
    )
    assert message.valid?
  end

  test "should require company" do
    message = Message.new(
      conversation: @conversation,
      sender: @sender,
      body: "Test message"
    )
    assert_not message.valid?
    assert_includes message.errors[:company], "must exist"
  end

  test "should require conversation" do
    message = Message.new(
      company: @company,
      sender: @sender,
      body: "Test message"
    )
    assert_not message.valid?
    assert_includes message.errors[:conversation], "must exist"
  end

  test "should require sender" do
    message = Message.new(
      company: @company,
      conversation: @conversation,
      body: "Test message"
    )
    assert_not message.valid?
    assert_includes message.errors[:sender], "must exist"
  end

  test "should require body" do
    message = Message.new(
      company: @company,
      conversation: @conversation,
      sender: @sender
    )
    assert_not message.valid?
    assert_includes message.errors[:body], "can't be blank"
  end

  test "should not allow empty body" do
    message = Message.new(
      company: @company,
      conversation: @conversation,
      sender: @sender,
      body: ""
    )
    assert_not message.valid?
    assert_includes message.errors[:body], "can't be blank"
  end

  test "should not allow whitespace-only body" do
    message = Message.new(
      company: @company,
      conversation: @conversation,
      sender: @sender,
      body: "   "
    )
    assert_not message.valid?
    assert_includes message.errors[:body], "can't be blank"
  end

  test "should belong to sender as User class" do
    message = messages(:acme_admin_message)
    assert_instance_of User, message.sender
    assert_equal users(:acme_admin), message.sender
  end

  test "fixtures should be valid" do
    assert messages(:acme_admin_message).valid?
    assert messages(:acme_resident_reply).valid?
    assert messages(:downtown_admin_message).valid?
  end
end
