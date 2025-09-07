# Tower Admin Test Suite

This directory contains comprehensive tests for the Tower Admin application, covering models, controllers, and system-level functionality.

## Test Structure

```
test/
├── fixtures/           # Test data fixtures
├── models/            # Model unit tests
├── controllers/       # Controller integration tests
├── system/           # End-to-end browser tests
├── support/          # Helper modules and shared code
└── mailers/          # Email functionality tests
```

## Test Types

### 🧪 **Model Tests** (`test/models/`)
- **Company**: Validation, business logic, tenant isolation
- **User**: Authentication, roles, permissions, associations
- **Resident**: Invitation system, validation, multi-tenant scope
- **Building/Apartment**: Property management functionality
- **Notification**: Communication system logic

### 🎛️ **Controller Tests** (`test/controllers/`)
- **Authentication & Authorization**: Login, permissions, role-based access
- **Multi-tenant Routing**: Subdomain-based tenant switching
- **CRUD Operations**: Create, read, update, delete functionality
- **API Endpoints**: JSON responses, AJAX requests

### 🖥️ **System Tests** (`test/system/`)
- **Admin Dashboard**: Super admin and company admin workflows
- **Resident Portal**: Resident dashboard and notifications
- **Invitation Flow**: End-to-end resident onboarding
- **Multi-tenant Isolation**: Cross-tenant security testing

### 📧 **Mailer Tests** (`test/mailers/`)
- **Notification Emails**: Email delivery and content
- **Invitation Emails**: Resident invitation system
- **Email Previews**: Development email testing

## Test Data (Fixtures)

Our fixtures provide realistic test data:

### Companies
- **ACME Properties** (`acme_properties`) - Pro plan, 10 buildings max
- **Downtown Management** (`downtown_management`) - Basic plan, 5 buildings max
- **Enterprise Corp** (`enterprise_corp`) - Enterprise plan, 50 buildings max

### Users
- **Super Admin** (`super_admin`) - Platform administrator
- **Company Admins** - Per-company administrators
- **Managers** - Building management staff
- **Residents** - Tenant users with portal access

### Buildings & Apartments
- **ACME Tower** - Multi-unit building with various apartment types
- **Downtown Plaza** - Different company's property
- **Enterprise Center** - Large-scale property

## Running Tests

### All Tests
```bash
# Run the complete test suite
rails test

# Run tests in parallel for faster execution
rails test --parallel
```

### Specific Test Types
```bash
# Model tests only
rails test test/models

# Controller tests only
rails test test/controllers

# System tests only (requires browser)
rails test:system

# Single test file
rails test test/models/company_test.rb

# Single test method
rails test test/models/company_test.rb::test_should_be_valid_with_valid_attributes
```

### Test Coverage
```bash
# Generate coverage report (if SimpleCov is configured)
COVERAGE=true rails test
```

## Test Helpers

### Authentication Helpers (`test/support/authentication_helpers.rb`)

Convenient methods for testing authentication scenarios:

```ruby
# Sign in users
sign_in_as_super_admin
sign_in_as_admin(:acme_properties)
sign_in_as_resident(:acme_resident)

# Test authentication requirements
assert_requires_authentication(path)
assert_requires_super_admin(path)

# Multi-tenant testing
with_tenant(:acme_properties) do |company|
  # Test within tenant context
end
```

### Model Helpers

```ruby
# Validate model errors
assert_errors_on(model, :attribute1, :attribute2)
assert_no_errors_on(model, :attribute1, :attribute2)
```

### System Test Helpers

```ruby
# Browser-based authentication
sign_in_for_system_test(user, subdomain: "acme")
```

## Testing Multi-tenancy

Multi-tenant functionality is thoroughly tested:

### Tenant Isolation
- Users can only access their company's data
- Cross-tenant data leaks are prevented
- Subdomain routing works correctly

### Authentication & Authorization
- Role-based permissions are enforced
- Super admin access is properly restricted
- Resident access is limited to their portal

### Data Integrity
- Company-scoped queries work correctly
- Notifications target appropriate residents
- Building/apartment assignments respect tenant boundaries

## Testing Strategies

### 🔒 **Security Testing**
- Authentication bypass attempts
- Authorization escalation attempts
- Cross-tenant data access attempts
- Input validation and sanitization

### 🌐 **Multi-tenant Testing**
- Subdomain routing accuracy
- Tenant data isolation
- Cross-tenant operation prevention
- Tenant-specific branding/configuration

### 📱 **User Experience Testing**
- Complete user workflows
- Error handling and validation
- Form submissions and redirects
- AJAX interactions

### 🔄 **Integration Testing**
- Database transactions
- Email delivery
- Background job processing
- External service integration

## Continuous Integration

Tests are designed to run in CI/CD environments:

### Database Setup
```bash
# Prepare test database
rails db:test:prepare
```

### Environment Variables
```bash
RAILS_ENV=test
DATABASE_URL=postgres://user:pass@localhost/tower_admin_test
```

### Headless Browser Testing
System tests use headless Chrome by default for CI compatibility.

## Writing New Tests

### Model Tests
```ruby
class NewModelTest < ActiveSupport::TestCase
  def setup
    @model = new_models(:fixture_name)
  end

  test "should validate required attributes" do
    @model.required_field = nil
    assert_not @model.valid?
    assert_includes @model.errors[:required_field], "can't be blank"
  end
end
```

### Controller Tests
```ruby
class NewControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:admin_user)
    sign_in_user(@user)
  end

  test "should get index" do
    get new_models_path
    assert_response :success
  end
end
```

### System Tests
```ruby
class NewSystemTest < ApplicationSystemTestCase
  test "user can complete workflow" do
    sign_in_for_system_test(users(:admin_user))
    
    visit new_model_path
    fill_in "Name", with: "Test Name"
    click_button "Create"
    
    assert_text "Successfully created"
  end
end
```

## Test Maintenance

- **Fixtures**: Keep test data realistic and up-to-date
- **Helper Methods**: DRY principles for common test operations  
- **Factories**: Consider FactoryBot for complex test data
- **Cleanup**: Ensure tests don't leave persistent state
- **Performance**: Monitor test suite execution time

## Debugging Tests

```bash
# Run single test with debugging
rails test test/models/company_test.rb -v

# Use debugger in tests
binding.pry # Add to test code

# Check test database state
rails db -e test
```

---

**Test Quality Guidelines:**
- Each test should be independent and isolated
- Use descriptive test names that explain the behavior
- Follow AAA pattern: Arrange, Act, Assert
- Test both happy path and error conditions
- Mock external dependencies appropriately