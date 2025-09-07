require "test_helper"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = companies(:acme_properties)
    @super_admin = users(:super_admin)
    sign_in @super_admin
  end

  test "should require super admin authentication" do
    sign_out @super_admin

    get companies_url(subdomain: "admin")
    assert_redirected_to new_user_session_url
  end

  test "should deny access to non-super-admin" do
    sign_out @super_admin
    sign_in users(:acme_admin)

    get companies_url(subdomain: "admin")
    assert_redirected_to new_user_session_url
  end

  test "should get index" do
    get companies_url(subdomain: "admin")
    assert_response :success
    assert_select "table"
  end

  test "should get new" do
    get new_company_url(subdomain: "admin")
    assert_response :success
    assert_select "form"
  end

  test "should create company with valid params" do
    assert_difference("Company.count") do
      post companies_url(subdomain: "admin"), params: {
        company: {
          domain: "new-company.com",
          max_buildings: 15,
          name: "New Company",
          plan: "pro",
          subdomain: "newcompany"
        }
      }
    end

    assert_redirected_to company_url(Company.last, subdomain: "admin")
    assert_equal "New Company", Company.last.name
  end

  test "should not create company with invalid params" do
    assert_no_difference("Company.count") do
      post companies_url(subdomain: "admin"), params: {
        company: {
          domain: "",
          max_buildings: 0,
          name: "",
          plan: "invalid",
          subdomain: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should show company" do
    get company_url(@company, subdomain: "admin")
    assert_response :success
    assert_select "h1", /#{@company.name}/
  end

  test "should get edit" do
    get edit_company_url(@company, subdomain: "admin")
    assert_response :success
    assert_select "form"
  end

  test "should update company with valid params" do
    patch company_url(@company, subdomain: "admin"), params: {
      company: {
        name: "Updated Company Name",
        max_buildings: 20
      }
    }

    assert_redirected_to company_url(@company, subdomain: "admin")
    @company.reload
    assert_equal "Updated Company Name", @company.name
    assert_equal 20, @company.max_buildings
  end

  test "should not update company with invalid params" do
    original_name = @company.name

    patch company_url(@company, subdomain: "admin"), params: {
      company: {
        name: "",
        plan: "invalid"
      }
    }

    assert_response :unprocessable_entity
    @company.reload
    assert_equal original_name, @company.name
  end

  test "should destroy company" do
    assert_difference("Company.count", -1) do
      delete company_url(@company, subdomain: "admin")
    end

    assert_redirected_to companies_url(subdomain: "admin")
  end

  private

  def sign_in(user)
    post new_user_session_url(subdomain: "admin"),
         params: { user: { email: user.email, password: "password123" } }
  end

  def sign_out(user)
    delete destroy_user_session_url(subdomain: "admin")
  end
end
