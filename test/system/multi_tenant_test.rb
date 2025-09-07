require "application_system_test_case"

class MultiTenantTest < ApplicationSystemTestCase
  def setup
    @acme_admin = users(:acme_admin)
    @downtown_admin = users(:downtown_admin)
    @acme_company = companies(:acme_properties)
    @downtown_company = companies(:downtown_management)
  end

  test "users can only access their own company data" do
    # Sign in as ACME admin
    sign_in_for_system_test(@acme_admin, subdomain: "acme")

    visit buildings_path

    # Should see ACME buildings only
    assert_text @acme_company.buildings.first.name
    assert_no_text @downtown_company.buildings.first.name
  end

  test "tenant isolation prevents cross-tenant data access" do
    # Sign in as Downtown admin
    sign_in_for_system_test(@downtown_admin, subdomain: "downtown")

    visit buildings_path

    # Should see Downtown buildings only
    assert_text @downtown_company.buildings.first.name
    assert_no_text @acme_company.buildings.first.name
  end

  test "wrong subdomain redirects to correct tenant" do
    # Try to access ACME subdomain with Downtown admin
    visit "http://acme.localhost:3000"

    fill_in "Email", with: @downtown_admin.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    # Should be redirected or show error
    assert_no_text "Welcome to ACME Properties"
  end

  test "super admin can access admin portal from any subdomain" do
    super_admin = users(:super_admin)

    visit "http://admin.localhost:3000"

    fill_in "Email", with: super_admin.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    assert_text "Companies"
    assert_current_path admin_root_path
  end

  test "subdomain routing works correctly" do
    # Test ACME subdomain
    sign_in_for_system_test(@acme_admin, subdomain: "acme")
    visit tenant_root_path
    assert_text @acme_company.name

    # Test Downtown subdomain
    sign_in_for_system_test(@downtown_admin, subdomain: "downtown")
    visit tenant_root_path
    assert_text @downtown_company.name
  end

  test "company specific branding and data" do
    sign_in_for_system_test(@acme_admin, subdomain: "acme")

    visit tenant_root_path

    # Check that company-specific information is displayed
    assert_text @acme_company.name
    assert_text "Plan: #{@acme_company.plan.capitalize}"
    assert_text "#{@acme_company.buildings.count} Buildings"
  end
end
