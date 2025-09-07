require "application_system_test_case"

class AdminDashboardTest < ApplicationSystemTestCase
  def setup
    @super_admin = users(:super_admin)
    @admin_user = users(:acme_admin)
    @company = companies(:acme_properties)
  end

  test "super admin can access admin portal" do
    visit "http://admin.localhost:3000"
    
    fill_in "Email", with: @super_admin.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    assert_text "Companies"
    assert_current_path admin_root_path
  end

  test "super admin can create new company" do
    sign_in_for_system_test(@super_admin, subdomain: "admin")
    
    visit new_company_path
    
    fill_in "Name", with: "Test Property Company"
    fill_in "Domain", with: "testprop.com"
    fill_in "Subdomain", with: "testprop"
    select "Pro", from: "Plan"
    fill_in "Max buildings", with: "25"
    
    click_button "Create Company"
    
    assert_text "Test Property Company"
    assert Company.exists?(name: "Test Property Company")
  end

  test "regular admin cannot access admin portal" do
    visit "http://admin.localhost:3000"
    
    fill_in "Email", with: @admin_user.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    assert_text "Access denied"
    assert_current_path new_user_session_path
  end

  test "admin can access company dashboard" do
    visit "http://acme.localhost:3000"
    
    fill_in "Email", with: @admin_user.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    assert_text "Dashboard"
    assert_text @company.name
  end

  test "admin dashboard shows correct stats" do
    sign_in_for_system_test(@admin_user, subdomain: "acme")
    
    visit tenant_root_path
    
    assert_text "Buildings"
    assert_text "Apartments" 
    assert_text "Users"
    assert_text "Recent Buildings"
    assert_text "Recent Users"
  end
end