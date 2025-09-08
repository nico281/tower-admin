ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Load support files
Dir[Rails.root.join("test/support/**/*.rb")].each { |f| require f }

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    def assert_errors_on(model, *attributes)
      model.valid?
      attributes.each do |attribute|
        assert model.errors[attribute].any?, "Expected #{model.class.name} to have errors on #{attribute}"
      end
    end

    def assert_no_errors_on(model, *attributes)
      model.valid?
      attributes.each do |attribute|
        assert model.errors[attribute].empty?, "Expected #{model.class.name} to have no errors on #{attribute}, got: #{model.errors[attribute]}"
      end
    end
  end
end

# Configure Capybara for system tests
class ActionDispatch::SystemTestCase

  def sign_in_for_system_test(user, subdomain: nil)
    subdomain ||= user.company&.subdomain || "admin"
    
    # Configure Capybara to use the correct subdomain
    Capybara.app_host = "http://#{subdomain}.example.com"
    
    # Visit the sign-in path directly
    visit new_user_session_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Sign in"
  end
end
