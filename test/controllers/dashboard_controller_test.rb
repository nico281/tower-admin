require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin_user = users(:acme_admin)
    @resident_user = users(:acme_resident_user)
    @super_admin = users(:super_admin)
  end

  test "should require authentication" do
    get tenant_root_url(subdomain: "acme")
    assert_redirected_to new_user_session_url
  end

  test "admin should see admin dashboard" do
    sign_in @admin_user
    
    get tenant_root_url(subdomain: "acme")
    assert_response :success
    assert_select "h1", /Dashboard/i
    assert_template :index
  end

  test "resident should see resident dashboard" do
    sign_in @resident_user
    
    get tenant_root_url(subdomain: "acme")
    assert_response :success
    assert_template :resident_index
  end

  test "should set correct instance variables for admin dashboard" do
    sign_in @admin_user
    
    get tenant_root_url(subdomain: "acme")
    
    assert_not_nil assigns(:company)
    assert_not_nil assigns(:buildings_count)
    assert_not_nil assigns(:apartments_count)
    assert_not_nil assigns(:users_count)
    assert_not_nil assigns(:recent_buildings)
    assert_not_nil assigns(:recent_users)
  end

  test "should set correct instance variables for resident dashboard" do
    sign_in @resident_user
    
    get tenant_root_url(subdomain: "acme")
    
    assert_not_nil assigns(:company)
    assert_not_nil assigns(:resident)
    assert_not_nil assigns(:building)
    assert_not_nil assigns(:apartment)
    assert_not_nil assigns(:recent_payments)
    assert_not_nil assigns(:pending_payments)
  end

  test "should respect tenant context" do
    sign_in @admin_user
    
    get tenant_root_url(subdomain: "acme")
    
    assert_equal companies(:acme_properties), assigns(:company)
  end

  private

  def sign_in(user)
    post new_user_session_url(subdomain: user.company&.subdomain || "admin"), 
         params: { user: { email: user.email, password: "password123" } }
  end
end