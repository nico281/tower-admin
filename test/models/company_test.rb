require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  def setup
    @company = companies(:acme_properties)
  end

  test "should be valid with valid attributes" do
    assert @company.valid?
  end

  test "should require name" do
    @company.name = nil
    assert_not @company.valid?
    assert_includes @company.errors[:name], "can't be blank"
  end

  test "should require domain" do
    @company.domain = nil
    assert_not @company.valid?
    assert_includes @company.errors[:domain], "can't be blank"
  end

  test "should require unique domain" do
    duplicate_company = @company.dup
    duplicate_company.subdomain = "different"
    assert_not duplicate_company.valid?
    assert_includes duplicate_company.errors[:domain], "has already been taken"
  end

  test "should require subdomain" do
    @company.subdomain = nil
    assert_not @company.valid?
    assert_includes @company.errors[:subdomain], "can't be blank"
  end

  test "should require unique subdomain" do
    duplicate_company = @company.dup
    duplicate_company.domain = "different.com"
    assert_not duplicate_company.valid?
    assert_includes duplicate_company.errors[:subdomain], "has already been taken"
  end

  test "should require valid plan" do
    assert_raises(ArgumentError) do
      @company.plan = "invalid_plan"
    end
  end

  test "should require max_buildings to be positive" do
    @company.max_buildings = 0
    assert_not @company.valid?
    assert_includes @company.errors[:max_buildings], "must be greater than or equal to 1"

    @company.max_buildings = -1
    assert_not @company.valid?
  end

  test "should have many users" do
    assert_respond_to @company, :users
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @company.users
  end

  test "should have many buildings" do
    assert_respond_to @company, :buildings
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @company.buildings
  end

  test "should destroy dependent users when company is destroyed" do
    user = users(:acme_admin)
    company = user.company
    expected_user_count = company.users.count

    assert_difference("User.count", -expected_user_count) do
      company.destroy
    end
  end

  test "should destroy dependent buildings when company is destroyed" do
    building = buildings(:acme_tower)
    company = building.company

    assert_difference("Building.count", -1) do
      company.destroy
    end
  end

  test "can_add_building? should return true when under limit" do
    company = companies(:acme_properties)
    assert company.can_add_building?
  end

  test "can_add_building? should return false when at limit" do
    company = companies(:acme_properties)
    company.max_buildings = company.buildings.count
    assert_not company.can_add_building?
  end

  test "enum should work for plans" do
    assert_equal "pro", @company.plan
    assert @company.pro?

    @company.basic!
    assert @company.basic?
    assert_equal "basic", @company.plan
  end
end
