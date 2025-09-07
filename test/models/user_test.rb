require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @admin_user = users(:acme_admin)
    @super_admin = users(:super_admin)
    @resident_user = users(:acme_resident_user)
  end

  test "should be valid with valid attributes" do
    assert @admin_user.valid?
    assert @super_admin.valid?
    assert @resident_user.valid?
  end

  test "should require email" do
    @admin_user.email = nil
    assert_not @admin_user.valid?
    assert_includes @admin_user.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    duplicate_user = @admin_user.dup
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "should require valid email format" do
    @admin_user.email = "invalid-email"
    assert_not @admin_user.valid?
    assert_includes @admin_user.errors[:email], "is invalid"
  end

  test "should belong to company" do
    assert_respond_to @admin_user, :company
    assert_equal companies(:acme_properties), @admin_user.company
  end

  test "should belong to resident" do
    assert_respond_to @resident_user, :resident
    assert_equal residents(:acme_resident), @resident_user.resident
  end

  test "super_admin should not have company" do
    @super_admin.company = companies(:acme_properties)
    assert_not @super_admin.valid?
    assert_includes @super_admin.errors[:company_id], "cannot be selected for super admin users"
  end

  test "super_admin? method should work" do
    assert @super_admin.super_admin?
    assert_not @admin_user.super_admin?
  end

  test "resident user must have resident record" do
    @resident_user.resident = nil
    assert_not @resident_user.valid?
    assert_includes @resident_user.errors[:resident], "must be linked for resident users"
  end

  test "non-resident user can exist without resident record" do
    @admin_user.resident = nil
    assert @admin_user.valid?
  end

  test "display_name should return resident name when present" do
    expected_name = @resident_user.resident.display_name
    assert_equal expected_name, @resident_user.display_name
  end

  test "display_name should return email when no resident" do
    assert_equal @admin_user.email, @admin_user.display_name
  end

  test "should have role enum" do
    assert @admin_user.admin?
    assert @super_admin.super_admin?
    assert @resident_user.resident?

    @admin_user.manager!
    assert @admin_user.manager?
  end

  test "should validate role inclusion" do
    user = User.new(email: "test@example.com", password: "password123")

    user.role = "invalid_role"
    assert_not user.valid?
  end
end
