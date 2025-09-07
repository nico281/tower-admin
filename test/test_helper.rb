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
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  
  def sign_in_for_system_test(user, subdomain: nil)
    subdomain ||= user.company&.subdomain || "admin"
    host = subdomain == "admin" ? "admin.localhost" : "#{subdomain}.localhost"
    
    visit "http://#{host}:3000"
    
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Log in"
  end
end
