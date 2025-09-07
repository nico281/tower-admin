module AuthenticationHelpers
  def sign_in_user(user, subdomain: nil)
    subdomain ||= user.company&.subdomain || "admin"

    post new_user_session_url(subdomain: subdomain),
         params: { user: { email: user.email, password: "password123" } }

    follow_redirect! if response.redirect?
  end

  def sign_out_user(subdomain: "admin")
    delete destroy_user_session_url(subdomain: subdomain)
  end

  def sign_in_as_super_admin
    sign_in_user(users(:super_admin), subdomain: "admin")
  end

  def sign_in_as_admin(company = :acme_properties)
    user = case company
    when Symbol
             users("#{company}_admin".to_sym)
    else
             company.users.admin.first
    end

    sign_in_user(user, subdomain: user.company.subdomain)
  end

  def sign_in_as_resident(resident_name = :acme_resident)
    user = users("#{resident_name}_user".to_sym)
    sign_in_user(user, subdomain: user.company.subdomain)
  end

  def assert_requires_authentication(path, subdomain: nil)
    get path, params: { subdomain: subdomain }
    assert_redirected_to new_user_session_url
  end

  def assert_requires_super_admin(path)
    regular_admin = users(:acme_admin)
    sign_in_user(regular_admin, subdomain: "admin")

    get path
    assert_redirected_to new_user_session_url
  end

  def with_tenant(company_fixture_name)
    company = companies(company_fixture_name)
    ActsAsTenant.with_tenant(company) do
      yield company
    end
  end
end

# Include helpers in all test classes
class ActionDispatch::IntegrationTest
  include AuthenticationHelpers
end

class ActiveSupport::TestCase
  include AuthenticationHelpers
end
