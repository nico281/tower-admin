# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Development Commands

### Development Server
```bash
bin/dev                    # Start all services (Rails server + asset watchers)
rails server               # Start Rails server only
```

### Testing
```bash
bin/test                   # Run models, controllers, and system tests
bin/test models            # Run model tests only
bin/test controllers       # Run controller tests only
bin/test system            # Run system tests only
bin/test all               # Run all tests
bin/test lint              # Run RuboCop and Brakeman

# Standard Rails test commands
rails test                 # Run unit/integration tests
rails test:system          # Run system tests (Capybara/Selenium)
rails test test/models/specific_test.rb  # Run specific test file
```

### Code Quality
```bash
bin/rubocop                # Run Ruby linter
bin/rubocop -a             # Auto-fix RuboCop violations
bin/brakeman               # Run security scanner
bin/brakeman --quiet       # Run Brakeman with minimal output
```

### Database
```bash
rails db:create            # Create databases
rails db:migrate           # Run migrations
rails db:seed              # Seed database
rails db:test:prepare      # Prepare test database
```

### Assets
```bash
pnpm run build             # Build JavaScript assets
pnpm run build:watch       # Watch JavaScript assets
bin/rails tailwindcss:build  # Build CSS
bin/rails tailwindcss:watch  # Watch CSS
```

### Deployment
```bash
kamal setup                # Setup Kamal deployment
kamal deploy               # Deploy to production
```

## Architecture Overview

### Multi-Tenant SaaS Application
Tower Admin is a **Ruby on Rails 8.0** multi-tenant property management platform with subdomain-based tenant isolation:

- **Admin Portal** (`admin.domain.com`) - Super admin management interface
- **Company Portals** (`company.domain.com`) - Tenant-specific property management interfaces

### Key Architectural Components

#### Multi-Tenancy Implementation
- **acts_as_tenant gem** provides tenant isolation
- **Subdomain routing** separates admin and company interfaces
- **Tenant scoping** ensures data isolation between companies
- **ApplicationController** handles tenant switching and authentication

#### Core Models Hierarchy
```
Company (tenant root)
├── Users (admin, manager, accountant roles)
├── Buildings
│   └── Apartments
│       ├── Residents (with optional User accounts)
│       └── Payments
└── Notifications
    └── NotificationRecipients
```

#### Authentication & Authorization
- **Devise** for user authentication with custom session controllers
- **Role-based permissions**: super_admin, admin, manager, accountant, resident
- **Tenant isolation**: Super admins operate without tenant scope, others are scoped to their company

#### Data Flow
1. **Request** → Subdomain detection → Tenant setting → Authentication
2. **Admin subdomain** → No tenant scoping → Super admin operations
3. **Company subdomain** → Tenant scoping → Company-specific operations

### Technology Stack
- **Backend**: Ruby on Rails 8.0.2, PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus), TailwindCSS 4.3
- **Assets**: ESBuild + Propshaft, pnpm for JavaScript packages
- **Background Jobs**: Solid Queue, Solid Cache, Solid Cable
- **Testing**: Capybara + Selenium WebDriver for system tests
- **Deployment**: Docker + Kamal, Thruster for production

### Important Files & Patterns

#### Controllers
- `ApplicationController` - Tenant switching, authentication, authorization helpers
- `*Controller` - Company portal controllers (tenant-scoped)
- `users/sessions_controller.rb` - Custom Devise authentication

#### Models
- `ApplicationRecord` - Base model class
- `User` - Central authentication model with role enum
- `Company` - Tenant root model with plan limits
- All tenant models use `acts_as_tenant(:company)`

#### Routes
- `config/routes.rb` - Subdomain-based routing with constraints
- Separate route trees for admin and company subdomains
- Devise integration with custom controllers

### Development Notes

#### Local Subdomain Setup
Add to `/etc/hosts` for local development:
```
127.0.0.1 admin.localhost
127.0.0.1 [company-name].localhost
```

#### Asset Pipeline
- **JavaScript**: ESBuild bundles `app/javascript/*` to `app/assets/builds`
- **CSS**: TailwindCSS processes styles
- **Development**: Use `bin/dev` to run all watchers simultaneously

#### Testing Strategy
- **Models**: Unit tests for business logic and validations
- **Controllers**: Integration tests for authentication and authorization
- **System**: End-to-end browser tests for user workflows
- **Multi-tenancy**: Ensure proper tenant scoping in all tests