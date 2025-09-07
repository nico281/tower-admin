# 🏢 Tower Admin

**Tower Admin** is a comprehensive multi-tenant property management platform built with Ruby on Rails 8.0. Designed for property management companies to efficiently manage their building portfolios, residents, and communications through a modern, intuitive web interface.

[![Ruby Version](https://img.shields.io/badge/ruby-3.4.5-red.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/rails-8.0.2-red.svg)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/postgresql-latest-blue.svg)](https://www.postgresql.org/)

## 🚀 Features

### 🏗️ **Multi-Tenant Architecture**
- **Admin Portal** (`admin.domain.com`) - Super admin management interface
- **Company Portals** (`company.domain.com`) - Tenant-specific property management
- **Resident Portals** - Dedicated interfaces for residents

### 🏢 **Property Management**
- **Building Management** - Complete building portfolio oversight
- **Apartment Tracking** - Detailed unit specifications (floor, bedrooms, bathrooms, size)
- **Resident Management** - Comprehensive tenant information and contact details
- **Payment Tracking** - Financial oversight with payment status monitoring

### 📢 **Communication System**
- **Targeted Notifications** - Building or apartment-specific messaging
- **Priority Levels** - Urgent, normal, and low priority communications
- **Read Receipts** - Track notification delivery and engagement
- **Resident Notification Portal** - Dedicated inbox for residents

### 🔐 **Security & Access Control**
- **Role-Based Permissions** - Super admin, admin, manager, accountant, resident roles
- **Invitation System** - Secure resident onboarding with token-based invitations
- **Tenant Isolation** - Complete data segregation between companies
- **Authentication** - Powered by Devise with custom session handling

## 🛠️ Tech Stack

- **Backend**: Ruby on Rails 8.0.2
- **Database**: PostgreSQL with multi-tenant support
- **Frontend**: Hotwire (Turbo + Stimulus), TailwindCSS 4.3
- **Authentication**: Devise
- **Multi-tenancy**: acts_as_tenant gem
- **Asset Pipeline**: ESBuild + Propshaft
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable
- **Deployment**: Docker with Kamal
- **Testing**: Capybara, Selenium WebDriver

## 📋 Prerequisites

Before setting up Tower Admin, ensure you have the following installed:

- **Ruby 3.4.5** - [Install via RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv)
- **Node.js** (Latest LTS) - [Download here](https://nodejs.org/)
- **PostgreSQL** (13+) - [Installation guide](https://www.postgresql.org/download/)
- **pnpm** or **Yarn** - JavaScript package manager

## 🚦 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/tower-admin.git
cd tower-admin
```

### 2. Install Dependencies
```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies
pnpm install
# or yarn install
```

### 3. Database Setup
```bash
# Create and setup databases
rails db:create
rails db:migrate
rails db:seed
```

### 4. Start Development Server
```bash
# Start all services (Rails + asset watchers)
bin/dev

# Or start Rails server only
rails server
```

### 5. Access the Application
- **Admin Portal**: http://admin.localhost:3000
- **Company Portal**: http://[company-subdomain].localhost:3000

## 🔧 Development Setup

### Environment Configuration
Create necessary environment files:

```bash
# Copy example environment file (if exists)
cp .env.example .env
```

### Database Configuration
The application uses PostgreSQL with multiple databases:
- `tower_admin_development` - Main application data
- `tower_admin_production_cache` - Caching (production)
- `tower_admin_production_queue` - Background jobs (production)
- `tower_admin_production_cable` - WebSocket connections (production)

### Running Tests

#### Local Development
```bash
# Use the custom test runner (recommended)
bin/test                    # Run models + controllers + system tests
bin/test models            # Run model tests only
bin/test controllers       # Run controller tests only  
bin/test system           # Run system tests only
bin/test lint             # Run RuboCop and Brakeman

# Standard Rails test commands
rails test                # Run all unit/integration tests
rails test:system         # Run system tests (browser-based)
rails test test/models/company_test.rb  # Run specific test file
```

#### CI/CD (GitHub Actions)
The project includes a comprehensive GitHub Actions workflow that:
- Runs tests against PostgreSQL
- Executes model, controller, and system tests
- Performs code quality checks (RuboCop, Brakeman)
- Tests against Ruby 3.4.5 and Node.js 20

### Code Quality Tools
```bash
# Run RuboCop linter
bin/rubocop

# Run Brakeman security scanner
bin/brakeman

# Auto-fix RuboCop violations
bin/rubocop -a
```

### Asset Management
```bash
# Build assets for production
pnpm run build

# Watch assets during development
pnpm run build:watch
```

## 🏢 Multi-Tenant Setup

### Creating a Company
1. Access admin portal at `http://admin.localhost:3000`
2. Sign in with super admin credentials
3. Navigate to Companies → New Company
4. Set subdomain (e.g., 'acme' for acme.localhost:3000)

### Subdomain Configuration
For local development, add entries to your `/etc/hosts` file:
```
127.0.0.1 admin.localhost
127.0.0.1 acme.localhost
127.0.0.1 demo.localhost
```

Or use a tool like [Puma-dev](https://github.com/puma/puma-dev) for automatic subdomain routing.

## 👥 User Roles & Permissions

| Role | Admin Portal | Company Portal | Capabilities |
|------|-------------|----------------|--------------|
| **Super Admin** | ✅ | ❌ | Manage all companies and users |
| **Admin** | ❌ | ✅ | Full company management |
| **Manager** | ❌ | ✅ | Building and resident management |
| **Accountant** | ❌ | ✅ | Payment and financial tracking |
| **Resident** | ❌ | ✅ | Personal dashboard and notifications |

## 🚀 Deployment

### Using Kamal (Recommended)
Tower Admin comes pre-configured with Kamal for Docker deployment:

```bash
# Setup deployment configuration
kamal setup

# Deploy to production
kamal deploy
```

### Manual Server Deployment
1. Setup PostgreSQL database
2. Configure environment variables
3. Build and deploy Docker container
4. Run database migrations
5. Configure reverse proxy (nginx/Apache)

### Platform as a Service (PaaS)
Tower Admin works great with:
- **Railway** - Connect your Git repo for auto-deployment
- **Render** - Use the included `render.yaml` configuration
- **Fly.io** - Deploy with `fly launch`
- **Heroku** - Standard Rails deployment process

## 🔒 Security

### Environment Variables
Required environment variables for production:

```bash
TOWER_ADMIN_DATABASE_PASSWORD=your_secure_password
SECRET_KEY_BASE=your_rails_secret_key
RAILS_MASTER_KEY=your_master_key
```

### Security Features
- **CSRF Protection** - Built-in Rails CSRF tokens
- **SQL Injection Prevention** - ActiveRecord parameterized queries
- **XSS Protection** - Content Security Policy headers
- **Secure Headers** - Security-focused HTTP headers
- **Modern Browser Requirements** - Automatic compatibility checking

## 📚 API Documentation

### GraphQL API (Future)
Tower Admin is designed to support a GraphQL API for mobile apps and third-party integrations.

### REST Endpoints
Current REST endpoints are used internally by the web interface.

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**: Follow Rails and Ruby best practices
4. **Write tests**: Ensure all new code is tested
5. **Run the linters**: `bin/rubocop` and fix any issues
6. **Commit your changes**: Use conventional commit messages
7. **Push to the branch**: `git push origin feature/amazing-feature`
8. **Open a Pull Request**: Describe your changes and testing approach

### Code Style
- Follow the existing code style
- Use RuboCop for Ruby linting
- Write descriptive commit messages
- Add tests for new functionality
- Update documentation as needed

## 📝 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 🆘 Support

- **Documentation**: Check this README and inline code comments
- **Issues**: Report bugs and request features via [GitHub Issues](https://github.com/your-username/tower-admin/issues)
- **Discussions**: Join community discussions on [GitHub Discussions](https://github.com/your-username/tower-admin/discussions)

## 🗺️ Roadmap

### Upcoming Features
- [ ] Mobile API (GraphQL)
- [ ] Advanced reporting and analytics
- [ ] Maintenance request system
- [ ] Document management
- [ ] Payment processing integration
- [ ] Mobile push notifications
- [ ] Multi-language support

---

**Tower Admin** - Simplifying property management for the modern world 🏢✨