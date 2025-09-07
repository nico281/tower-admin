require "test_helper"

class ResidentTest < ActiveSupport::TestCase
  def setup
    @resident = residents(:acme_resident)
    @invited_resident = residents(:invited_resident)
  end

  test "should be valid with valid attributes" do
    assert @resident.valid?
  end

  test "should require email" do
    @resident.email = nil
    assert_not @resident.valid?
    assert_includes @resident.errors[:email], "can't be blank"
  end

  test "should require unique email within company scope" do
    duplicate_resident = @resident.dup
    assert_not duplicate_resident.valid?
    assert_includes duplicate_resident.errors[:email], "has already been taken"
  end

  test "should allow same email in different companies" do
    different_company_resident = Resident.new(
      email: @resident.email,
      apartment: apartments(:downtown_301),
      company: companies(:downtown_management)
    )
    assert different_company_resident.valid?
  end

  test "should belong to apartment" do
    assert_respond_to @resident, :apartment
    assert_equal apartments(:acme_101), @resident.apartment
  end

  test "should belong to company" do
    assert_respond_to @resident, :company
    assert_equal companies(:acme_properties), @resident.company
  end

  test "should have one user" do
    assert_respond_to @resident, :user
    assert_equal users(:acme_resident_user), @resident.user
  end

  test "should have many payments" do
    assert_respond_to @resident, :payments
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @resident.payments
  end

  test "should delegate building to apartment" do
    assert_respond_to @resident, :building
    assert_equal @resident.apartment.building, @resident.building
  end

  test "full_name should combine first and last name" do
    assert_equal "John Doe", @resident.full_name
  end

  test "full_name should return nil when names are blank" do
    resident = Resident.new(first_name: "", last_name: "")
    assert_nil resident.full_name
  end

  test "display_name should return full_name when available" do
    assert_equal @resident.full_name, @resident.display_name
  end

  test "display_name should return email when no full_name" do
    resident = Resident.new(email: "test@example.com", first_name: "", last_name: "")
    assert_equal "test@example.com", resident.display_name
  end

  test "should validate phone number format" do
    @resident.phone = "invalid-phone"
    assert_not @resident.valid?
    assert_includes @resident.errors[:phone], "must be a valid phone number"

    @resident.phone = "+1-555-123-4567"
    assert @resident.valid?
  end

  test "should allow blank phone number" do
    @resident.phone = ""
    assert @resident.valid?
  end

  test "should validate name length" do
    @resident.first_name = "a" * 51
    assert_not @resident.valid?

    @resident.first_name = "a" * 50
    assert @resident.valid?
  end

  test "should validate unique invitation_token" do
    @resident.invitation_token = @invited_resident.invitation_token
    assert_not @resident.valid?
    assert_includes @resident.errors[:invitation_token], "has already been taken"
  end

  test "invited? should return true when invited_at is present" do
    assert @invited_resident.invited?
    assert_not @resident.invited?
  end

  test "invitation_pending? should return true when invited but not accepted" do
    assert @invited_resident.invitation_pending?
    assert_not @resident.invitation_pending?
  end

  test "invitation_accepted? should return true when invitation_accepted_at is present" do
    @invited_resident.invitation_accepted_at = Time.current
    assert @invited_resident.invitation_accepted?
    assert_not @resident.invitation_accepted?
  end

  test "generate_invitation_token! should set token and invited_at" do
    resident = residents(:downtown_resident)

    assert_nil resident.invitation_token
    assert_nil resident.invited_at

    resident.generate_invitation_token!

    assert_not_nil resident.invitation_token
    assert_not_nil resident.invited_at
    assert resident.persisted?
  end

  test "generate_invitation_token! should create unique token" do
    resident1 = residents(:downtown_resident)
    resident2 = Resident.create!(
      email: "unique@example.com",
      apartment: apartments(:downtown_301),
      company: companies(:downtown_management)
    )

    resident1.generate_invitation_token!
    resident2.generate_invitation_token!

    assert_not_equal resident1.invitation_token, resident2.invitation_token
  end
end
