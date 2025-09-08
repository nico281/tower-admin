require "application_system_test_case"

class CompaniesTest < ApplicationSystemTestCase
  setup do
    @company = companies(:one)
    @super_admin = users(:super_admin)
  end

  test "visiting the index" do
    sign_in_for_system_test(@super_admin, subdomain: "admin")
    visit companies_url
    assert_selector "h1", text: "Companies"
  end

  test "should create company" do
    sign_in_for_system_test(@super_admin, subdomain: "admin")
    visit companies_url
    click_on "New Company"

    fill_in "Domain", with: "new-company.com"
    fill_in "Max buildings", with: "5"
    fill_in "Name", with: "New Test Company"
    select "Pro", from: "Plan"
    fill_in "Subdomain", with: "newtest"
    click_on "Create Company"

    assert_text "Company was successfully created"
    click_on "Back"
  end

  test "should update Company" do
    sign_in_for_system_test(@super_admin, subdomain: "admin")
    visit company_url(@company)
    click_on "Edit", match: :first

    fill_in "Domain", with: @company.domain
    fill_in "Max buildings", with: @company.max_buildings
    fill_in "Name", with: @company.name
    select @company.plan.capitalize, from: "Plan"
    fill_in "Subdomain", with: @company.subdomain
    click_on "Update Company"

    assert_text "Company was successfully updated"
    click_on "Back"
  end

  test "should destroy Company" do
    sign_in_for_system_test(@super_admin, subdomain: "admin")
    visit company_url(@company)
    click_on "Delete", match: :first

    assert_text "Company was successfully destroyed"
  end
end
