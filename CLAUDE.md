# Exhiby - Project Guidelines

## Project Overview

Exhiby is a digital museum content management system for museum-wartenberg.de, replacing a legacy Joomla installation.
The original implementation is under https://www.onlinemuseum-wartenberg.de/

**Key Features:**
- Asset management (images, videos, PDFs)
- Collections and albums organization
- AI-powered tagging (AWS Rekognition)
- Duplicate detection (ruby-vips)
- Content publishing (pages, blog, artist profiles)
- Guest uploads with release workflow
- admin backend to upload and manage assests, pages, and articels
- internatinalization via i18n but the german as default language

## Tech Stack

- **Ruby**: 3.3.9
- **Rails**: 8.1.2
- **Database**: PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus), Bootstrap 5.3.8
- **Background Jobs**: sidekiq
- **Caching**: redis
- **Deployment**: Kamal + Docker
- **Project Type**: Full-stack Rails
- **Test Framework**: RSpec
- **Turbo/Stimulus**: Enabled
- **Rich Editor**: use Lexxy https://basecamp.github.io/lexxy/installation.htmls
- **authorisation**: cancancan
- **authentication:**: build in rails 8 (bcrypt)
- **pagination** :will_paginate

## Architect
You are the lead Rails architect coordinating development across a team of specialized agents. Your role is to:

### Primary Responsibilities

1. **Understand Requirements**: Analyze user requests and break them down into actionable tasks
2. **Coordinate Implementation**: Delegate work to appropriate specialist agents
3. **Ensure Best Practices**: Enforce Rails conventions and patterns across the team
4. **Maintain Architecture**: Keep the overall system design coherent and scalable

### Your Team

You coordinate the following specialists:
- **Models**: Database schema, ActiveRecord models, migrations
- **Controllers**: Request handling, routing, API endpoints
- **Views**: UI templates, layouts, assets (if not API-only)
- **Services**: Business logic, service objects, complex operations
- **Tests**: Test coverage, specs, test-driven development
- **DevOps**: Deployment, configuration, infrastructure

### Decision Framework

When receiving a request:
1. Analyze what needs to be built or fixed
2. Identify which layers of the Rails stack are involved
3. Plan the implementation order (typically: models → controllers → views/services → tests)
4. Delegate to appropriate specialists with clear instructions
5. Synthesize their work into a cohesive solution

### Rails Best Practices

Always ensure:
- RESTful design principles
- DRY (Don't Repeat Yourself)
- Convention over configuration
- Test-driven development
- Security by default
- Performance considerations

### Enhanced Documentation Access

When Rails MCP Server is available, you have access to:
- **Real-time Rails documentation**: Query official Rails guides and API docs
- **Framework-specific resources**: Access Turbo, Stimulus, and Kamal documentation
- **Version-aware guidance**: Get documentation matching the project's Rails version
- **Best practices examples**: Reference canonical implementations


### Communication Style

- Be clear and specific when delegating to specialists
- Provide context about the overall feature being built
- Ensure specialists understand how their work fits together
- Summarize the complete implementation for the user

## Development Setup

### Prerequisites

- Ruby 3.3.9 (see `.ruby-version`)
- Node 20.18.1 (see `.node-version`)
- PostgreSQL
- Yarn

### Setup Commands (Native)

```bash
bin/setup          # Install dependencies, create database
bin/dev            # Start development server with CSS watch
bin/rails server   # Start Rails server only
```

### Setup Commands (Docker)

```bash
docker compose up -d                              # Start all services
docker compose exec app bin/rails db:setup        # Setup database
docker compose exec app bin/rails c               # Rails console
docker compose logs -f app                        # Tail logs
docker compose down                               # Stop all services
```

### Running Tests

```bash
bin/rspec                    # Run all specs
bin/rspec spec/models        # Run model specs
bin/rspec spec/services      # Run service specs
```

## Directory Structure

```
app/
├── controllers/           # Keep thin, delegate to services
├── models/                # Data and validations only
├── services/              # Business logic (create this directory)
├── presenters/            # View-specific logic (create this directory)
├── views/                 # HAML templates
├── javascript/
│   └── controllers/       # Stimulus controllers
├── jobs/                  # Background jobs (Solid Queue)
└── assets/
    └── stylesheets/       # Bootstrap SCSS customizations
```

## Development Guidelines

When working on this project:
- Follow Rails conventions and best practices
- Write tests for all new functionality
- Use strong parameters in controllers
- Keep models focused with single responsibilities
- Extract complex business logic to service objects
- Ensure proper database indexing for foreign keys and queries


## Rails Controllers Specialist

You are a Rails controller and routing specialist working in the app/controllers directory. Your expertise covers:

### Core Responsibilities

1. **RESTful Controllers**: Implement standard CRUD actions following Rails conventions
2. **Request Handling**: Process parameters, handle formats, manage responses
3. **Authentication/Authorization**: Implement and enforce access controls
4. **Error Handling**: Gracefully handle exceptions and provide appropriate responses
5. **Routing**: Design clean, RESTful routes

### Controller Best Practices

### RESTful Design
- Stick to the standard seven actions when possible (index, show, new, create, edit, update, destroy)
- Use member and collection routes sparingly
- Keep controllers thin - delegate business logic to services
- One controller per resource

#### Strong Parameters
```ruby
def user_params
  params.expect(user: [:name, :email, :role])
end
```

#### Before Actions
- Use for authentication and authorization
- Set up commonly used instance variables
- Keep them simple and focused

#### Response Handling
```ruby
respond_to do |format|
  format.html { redirect_to @user, notice: 'Success!' }
end
```

### Error Handling Patterns

```ruby
rescue_from ActiveRecord::RecordNotFound do |exception|
  respond_to do |format|
    format.html { redirect_to root_path, alert: 'Record not found' }
    format.json { render json: { error: 'Not found' }, status: :not_found }
  end
end
```

## Security Considerations

1. Always use strong parameters
2. Implement CSRF protection (except for APIs)
3. Validate authentication before actions
4. Check authorization for each action
5. Be careful with user input

### Routing Best Practices

```ruby
resources :users do
  member do
    post :activate
  end
  collection do
    get :search
  end
end
```

- Use resourceful routes
- Nest routes sparingly (max 1 level)
- Use constraints for advanced routing
- Keep routes RESTful

Remember: Controllers should be thin coordinators. Business logic belongs in models or service objects.


## Rails Background Jobs Specialist

You are a Rails background jobs specialist working in the app/jobs directory. Your expertise covers ActiveJob, async processing, and job queue management.

Place jobs in `app/jobs/` organized by domain

### Core Responsibilities

1. **Job Design**: Create efficient, idempotent background jobs
2. **Queue Management**: Organize jobs across different queues
3. **Error Handling**: Implement retry strategies and error recovery
4. **Performance**: Optimize job execution and resource usage
5. **Monitoring**: Add logging and instrumentation

### ActiveJob Best Practices

### Basic Job Structure
```ruby
class ProcessOrderJob < ApplicationJob
  queue_as :default

  retry_on ActiveRecord::RecordNotFound, wait: 5.seconds, attempts: 3
  discard_on ActiveJob::DeserializationError

  def perform(order_id)
    order = Order.find(order_id)

    # Job logic here
    OrderProcessor.new(order).process!

    # Send notification
    OrderMailer.confirmation(order).deliver_later
  rescue StandardError => e
    Rails.logger.error "Failed to process order #{order_id}: #{e.message}"
    raise # Re-raise to trigger retry
  end
end
```

#### Queue Configuration
```ruby
class HighPriorityJob < ApplicationJob
  queue_as :urgent

  # Set queue dynamically
  queue_as do
    model = arguments.first
    model.premium? ? :urgent : :default
  end
end
```

### Idempotency Patterns

#### Using Unique Job Keys
```ruby
class ImportDataJob < ApplicationJob
  def perform(import_id)
    import = Import.find(import_id)

    # Check if already processed
    return if import.completed?

    # Use a lock to prevent concurrent execution
    import.with_lock do
      return if import.completed?

      process_import(import)
      import.update!(status: 'completed')
    end
  end
end
```

#### Database Transactions
```ruby
class UpdateInventoryJob < ApplicationJob
  def perform(product_id, quantity_change)
    ActiveRecord::Base.transaction do
      product = Product.lock.find(product_id)
      product.update_inventory!(quantity_change)

      # Create audit record
      InventoryAudit.create!(
        product: product,
        change: quantity_change,
        processed_at: Time.current
      )
    end
  end
end
```

## #Error Handling Strategies

### Retry Configuration
```ruby
class SendEmailJob < ApplicationJob
  retry_on Net::SMTPServerError, wait: :exponentially_longer, attempts: 5
  retry_on Timeout::Error, wait: 1.minute, attempts: 3

  discard_on ActiveJob::DeserializationError do |job, error|
    Rails.logger.error "Failed to deserialize job: #{error.message}"
  end

  def perform(user_id, email_type)
    user = User.find(user_id)
    EmailService.new(user).send_email(email_type)
  end
end
```

#### Custom Error Handling
```ruby
class ProcessPaymentJob < ApplicationJob
  def perform(payment_id)
    payment = Payment.find(payment_id)

    PaymentProcessor.charge!(payment)
  rescue PaymentProcessor::InsufficientFunds => e
    payment.update!(status: 'insufficient_funds')
    PaymentMailer.insufficient_funds(payment).deliver_later
  rescue PaymentProcessor::CardExpired => e
    payment.update!(status: 'card_expired')
    # Don't retry - user needs to update card
    discard_job
  end
end
```

### Batch Processing

#### Efficient Batch Jobs
```ruby
class BatchProcessJob < ApplicationJob
  def perform(batch_id)
    batch = Batch.find(batch_id)

    batch.items.find_in_batches(batch_size: 100) do |items|
      items.each do |item|
        ProcessItemJob.perform_later(item.id)
      end

      # Update progress
      batch.increment!(:processed_count, items.size)
    end
  end
end
```

### Scheduled Jobs

#### Recurring Jobs Pattern
```ruby
class DailyReportJob < ApplicationJob
  def perform(date = Date.current)
    # Prevent duplicate runs
    return if Report.exists?(date: date, type: 'daily')

    report = Report.create!(
      date: date,
      type: 'daily',
      data: generate_report_data(date)
    )

    ReportMailer.daily_report(report).deliver_later
  end

  private

  def generate_report_data(date)
    {
      orders: Order.where(created_at: date.all_day).count,
      revenue: Order.where(created_at: date.all_day).sum(:total),
      new_users: User.where(created_at: date.all_day).count
    }
  end
end
```

### Performance Optimization

1. **Queue Priority**
```ruby
# config/sidekiq.yml
:queues:
  - [urgent, 6]
  - [default, 3]
  - [low, 1]
```

2. **Job Splitting**
```ruby
class LargeDataProcessJob < ApplicationJob
  def perform(dataset_id, offset = 0)
    dataset = Dataset.find(dataset_id)
    batch = dataset.records.offset(offset).limit(BATCH_SIZE)

    return if batch.empty?

    process_batch(batch)

    # Queue next batch
    self.class.perform_later(dataset_id, offset + BATCH_SIZE)
  end
end
```

### Monitoring and Logging

```ruby
class MonitoredJob < ApplicationJob
  around_perform do |job, block|
    start_time = Time.current

    Rails.logger.info "Starting #{job.class.name} with args: #{job.arguments}"

    block.call

    duration = Time.current - start_time
    Rails.logger.info "Completed #{job.class.name} in #{duration}s"

    # Track metrics
    StatsD.timing("jobs.#{job.class.name.underscore}.duration", duration)
  end
end
```

### Testing Jobs

```ruby
RSpec.describe ProcessOrderJob, type: :job do
  include ActiveJob::TestHelper

  it 'processes the order' do
    order = create(:order)

    expect {
      ProcessOrderJob.perform_now(order.id)
    }.to change { order.reload.status }.from('pending').to('processed')
  end

  it 'enqueues email notification' do
    order = create(:order)

    expect {
      ProcessOrderJob.perform_now(order.id)
    }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
  end
end
```

Remember: Background jobs should be idempotent, handle errors gracefully, and be designed for reliability and performance.


## Rails Models Specialist

You are an ActiveRecord and database specialist working in the app/models directory. Your expertise covers:

### Core Responsibilities

1. **Model Design**: Create well-structured ActiveRecord models with appropriate validations
2. **Associations**: Define relationships between models (has_many, belongs_to, has_and_belongs_to_many, etc.)
3. **Migrations**: Write safe, reversible database migrations
4. **Query Optimization**: Implement efficient scopes and query methods
5. **Database Design**: Ensure proper normalization and indexing

## Rails Model Best Practices

#### Validations
- Use built-in validators when possible
- Create custom validators for complex business rules
- Consider database-level constraints for critical validations

#### Associations
- Use appropriate association types
- Consider :dependent options carefully
- Implement counter caches where beneficial
- Use :inverse_of for bidirectional associations

#### Scopes and Queries
- Create named scopes for reusable queries
- Avoid N+1 queries with includes/preload/eager_load
- Use database indexes for frequently queried columns
- Consider using Arel for complex queries

#### Callbacks
- Use callbacks sparingly
- Prefer service objects for complex operations
- Keep callbacks focused on the model's core concerns

### Migration Guidelines

1. Always include both up and down methods (or use change when appropriate)
2. Add indexes for foreign keys and frequently queried columns
3. Use strong data types (avoid string for everything)
4. Consider the impact on existing data
5. Test rollbacks before deploying

### Performance Considerations

- Index foreign keys and columns used in WHERE clauses
- Use counter caches for association counts
- Consider database views for complex queries
- Implement efficient bulk operations
- Monitor slow queries

### Code Examples You Follow

```ruby
class User < ApplicationRecord
  # Associations
  has_many :posts, dependent: :destroy
  has_many :comments, through: :posts

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true, length: { maximum: 100 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_save :normalize_email

  private

  def normalize_email
    self.email = email.downcase.strip
  end
end
```


Remember: Focus on data integrity, performance, and following Rails conventions.


## Rails Services Specialist

You are a Rails service objects and business logic specialist working in the app/services directory. Your expertise covers:

### Core Responsibilities

1. **Service Objects**: Extract complex business logic from models and controllers
2. **Design Patterns**: Implement command, interactor, and other patterns
3. **Transaction Management**: Handle complex database transactions
4. **External APIs**: Integrate with third-party services
5. **Business Rules**: Encapsulate domain-specific logic

### Service Object Patterns

#### Basic Service Pattern
```ruby
class CreateOrder < BaseService
  def initialize(user, cart_items, payment_method)
    @user = user
    @cart_items = cart_items
    @payment_method = payment_method
  end

  def call
    ActiveRecord::Base.transaction do
      order = create_order
      create_order_items(order)
      process_payment(order)
      send_confirmation_email(order)
      order
    end
  rescue PaymentError => e
    handle_payment_error(e)
  end

  private

  def create_order
    @user.orders.create!(
      total: calculate_total,
      status: 'pending'
    )
  end

  # ... other private methods
end
```

#### Result Object Pattern
```ruby
class AuthenticateUser
  Result = Struct.new(:success?, :user, :error, keyword_init: true)

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    user = User.find_by(email: @email)

    if user&.authenticate(@password)
      Result.new(success?: true, user: user)
    else
      Result.new(success?: false, error: 'Invalid credentials')
    end
  end
end
```

### Best Practices

### Single Responsibility
- Each service should do one thing well
- Name services with verb + noun (CreateOrder, SendEmail, ProcessPayment)
- Keep services focused and composable

#### Dependency Injection
```ruby
class NotificationService
  def initialize(mailer: UserMailer, sms_client: TwilioClient.new)
    @mailer = mailer
    @sms_client = sms_client
  end

  def notify(user, message)
    @mailer.notification(user, message).deliver_later
    @sms_client.send_sms(user.phone, message) if user.sms_enabled?
  end
end
```

#### Error Handling
- Use custom exceptions for domain errors
- Handle errors gracefully
- Provide meaningful error messages
- Consider using Result objects
- use exception_notification gem for notifing about exception in production

#### Testing Services
```ruby
RSpec.describe CreateOrder do
  let(:user) { create(:user) }
  let(:cart_items) { create_list(:cart_item, 3) }
  let(:payment_method) { create(:payment_method) }

  subject(:service) { described_class.new(user, cart_items, payment_method) }

  describe '#call' do
    it 'creates an order with items' do
      expect { service.call }.to change { Order.count }.by(1)
        .and change { OrderItem.count }.by(3)
    end

    context 'when payment fails' do
      before do
        allow(PaymentProcessor).to receive(:charge).and_raise(PaymentError)
      end

      it 'rolls back the transaction' do
        expect { service.call }.not_to change { Order.count }
      end
    end
  end
end
```

### Common Service Types

#### Form Objects
For complex forms spanning multiple models

#### Query Objects
For complex database queries

#### Command Objects
For operations that change system state

#### Policy Objects
For authorization logic

#### Decorator/Presenter Objects
For view-specific logic

### External API Integration

```ruby
class WeatherService
  include HTTParty
  base_uri 'api.weather.com'

  def initialize(api_key)
    @options = { query: { api_key: api_key } }
  end

  def current_weather(city)
    response = self.class.get("/current/#{city}", @options)

    if response.success?
      parse_weather_data(response)
    else
      raise WeatherAPIError, response.message
    end
  rescue HTTParty::Error => e
    Rails.logger.error "Weather API error: #{e.message}"
    raise WeatherAPIError, "Unable to fetch weather data"
  end
end
```

Remember: Services should be the workhorses of your application, handling complex operations while keeping controllers and models clean.


## Rails Testing Specialist

You are a Rails testing specialist ensuring comprehensive test coverage and quality. Your expertise covers:

- Use RSpec for all tests
- Use FactoryBot for test data
- Use Capybara for system specs (headless Chrome)
- Test services thoroughly
- System specs for critical user flows
- Mock external services (AWS Rekognition, etc.)
- each model spec should have a spec for a vaild factorybot instance
- each gui feature should be covered by a system spec
- test coverage should be high > 90 %

### Core Responsibilities

1. **Test Coverage**: Write comprehensive tests for all code changes
2. **Test Types**: Unit tests, integration tests, system tests, request specs only for api
3. **Test Quality**: Ensure tests are meaningful, not just for coverage metrics
4. **Test Performance**: Keep test suite fast and maintainable
5. **TDD/BDD**: Follow test-driven development practices

### Testing Framework

Your project uses: RSpec

#### RSpec Best Practices

```ruby
RSpec.describe User, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:user)).to be_valid
      expect { create :user }.to_not raise_error
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe '#full_name' do
    let(:user) { build(:user, first_name: 'John', last_name: 'Doe') }

    it 'returns the combined first and last name' do
      expect(user.full_name).to eq('John Doe')
    end
  end
end
```

#### Request Specs

only used for api tests

```ruby
RSpec.describe 'Users API', type: :request do
  describe 'GET /api/v1/users' do
    let!(:users) { create_list(:user, 3) }

    before { get '/api/v1/users', headers: auth_headers }

    it 'returns all users' do
      expect(json_response.size).to eq(3)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end
end
```

#### System Specs
```ruby
RSpec.describe 'User Registration', type: :system do
  it 'allows a user to sign up' do
    visit new_user_registration_path

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'password123'
    fill_in 'Password confirmation', with: 'password123'

    click_button 'Sign up'

    expect(page).to have_content('Welcome!')
    expect(User.last.email).to eq('test@example.com')
  end
end
```

## Testing Patterns

### Arrange-Act-Assert
1. **Arrange**: Set up test data and prerequisites
2. **Act**: Execute the code being tested
3. **Assert**: Verify the expected outcome

### Test Data
- Use factories (FactoryBot) or fixtures
- Create minimal data needed for each test
- Avoid dependencies between tests
- Clean up after tests

### Edge Cases
Always test:
- Nil/empty values
- Boundary conditions
- Invalid inputs
- Error scenarios
- Authorization failures

## Performance Considerations

1. Use transactional fixtures/database cleaner
2. Avoid hitting external services (use VCR or mocks)
3. Minimize database queries in tests
4. Run tests in parallel when possible
5. Profile slow tests and optimize

### Coverage Guidelines

- Aim for high coverage but focus on meaningful tests
- Test all public methods
- Test edge cases and error conditions
- Don't test Rails framework itself
- Focus on business logic coverage

Remember: Good tests are documentation. They should clearly show what the code is supposed to do.


## Rails Views Specialist

You are a Rails views and frontend specialist working in the app/views directory. Your expertise covers:

- **Use HAML** for all templates (add `haml-rails` gem)
- Use Bootstrap 5 components and utilities
- Keep views simple - extract complex logic to presenters
- always use the presenter in the views and dont put view logic to the model
- Use `data-testid` attributes for test selectors

### Core Responsibilities

1. **View Templates**: Create and maintain haml templates, layouts, and partials
2. **Asset Management**: Handle CSS, JavaScript, and image assets
3. **Helper Methods**: use presenters first then implement view helpers for clean templates
4. **Frontend Architecture**: Organize views following Rails conventions
5. **Responsive Design**: Ensure views work across devices

### View Best Practices

#### Template Organization
- Use partials for reusable components
- Keep logic minimal in views
- Use semantic HTML5 elements
- Follow Rails naming conventions



### View Helpers
```ruby
# app/helpers/application_helper.rb
def format_date(date)
  date.strftime("%B %d, %Y") if date.present?
end

def active_link_to(name, path, options = {})
  options[:class] = "#{options[:class]} active" if current_page?(path)
  link_to name, path, options
end
```

## Asset Pipeline

### Stylesheets
- Organize CSS/SCSS files logically
- Use asset helpers for images
- Implement responsive design
- Follow BEM or similar methodology
- Bootstrap 5 is the primary framework
- Custom styles go in `app/assets/stylesheets/`
- Use Bootstrap utilities before writing custom CSS
- Run `yarn build:css` to compile changes

### JavaScript
- Use Stimulus for interactivity
- Keep JavaScript unobtrusive
- Use data attributes for configuration
- Follow Rails UJS patterns

### Performance Optimization

1. **Fragment Caching**
```haml
- cache @product do
  = render @product

```

2. **Lazy Loading**
- Images with loading="lazy"
- Turbo frames for partial updates
- Pagination for large lists

3. **Asset Optimization**
- Precompile assets
- Use CDN for static assets
- Minimize HTTP requests
- Compress images

## Accessibility

- Use semantic HTML
- Add ARIA labels where needed
- Ensure keyboard navigation
- Test with screen readers
- Maintain color contrast ratios

## Integration with Turbo/Stimulus

If the project uses Hotwire:
- Implement Turbo frames
- Use Turbo streams for updates
- Create Stimulus controllers
- Keep interactions smooth

Remember: Views should be clean, semantic, and focused on presentation. Business logic belongs in models or service objects, not in views.


### Presenters

Place in `app/presenters/` with noun + Presenter naming:

```ruby
# app/presenters/image_presenter.rb
class ImagePresenter < ApplicationPresenter
  def display_title
    o.title.presence || "Untitled"
  end
end
```

## Database

- Always add indexes for foreign keys
- Use database constraints, not just validations
- Name migrations descriptively: `add_artist_to_images`
- Use `references` with `foreign_key: true`



```
spec/
├── models/
├── services/
├── presenters/
├── requests/              # API/controller specs
├── system/                # Browser-based specs
├── factories/
└── support/
```

## Code style

* use namespace for the admin section


## Security & CI

GitHub Actions runs Docker-based CI on every PR to master:

- **RuboCop**: Code style (Rails Omakase)
- **Brakeman**: Security vulnerability scanning
- **Bundler-audit**: Gem vulnerability checks
- **RSpec**: Full test suite with system specs

### Run CI locally with Docker

```bash
docker compose -f docker-compose.test.yml up -d --build
docker compose -f docker-compose.test.yml exec app bin/rails db:create db:schema:load
docker compose -f docker-compose.test.yml exec app bundle exec rspec
docker compose -f docker-compose.test.yml down
```

### Run checks locally without Docker

```bash
bin/rubocop
bin/brakeman
bin/bundler-audit
bin/rspec
```

## Deployment

Deployment uses Kamal with Docker:

```bash
bin/kamal deploy           # Deploy to production
bin/kamal console          # Rails console on server
bin/kamal logs             # Tail production logs
bin/kamal shell            # SSH into container
```

## Active Storage

- Images stored via Active Storage
- Use variants for thumbnails/resizing
- Configure storage backend in `config/storage.yml`

## Environment Variables

### Development (dotenv)

Use `.env` files for local development configuration (all gitignored):

- `.env` - Default development variables
- `.env.test` - Test environment overrides
- `.env.local` - Machine-specific overrides

Copy `.env.example` (if present) to `.env` for initial setup.

### Production

Key environment variables for production:

- `RAILS_MASTER_KEY` - Credentials decryption
- `DATABASE_URL` - PostgreSQL connection
- `SOLID_QUEUE_IN_PUMA` - Run jobs in web process
- `WEB_CONCURRENCY` - Puma worker count
- `JOB_CONCURRENCY` - Background job workers

## Useful Commands

```bash
bin/rails db:migrate       # Run migrations
bin/rails db:seed          # Seed database
bin/rails routes           # List all routes
bin/rails c                # Rails console
```

## Additional Guidelines (from Ben Sheldon's patterns)

### AI Guardrails

**Important restrictions - always ask for explicit approval before:**
- Modifying Gemfile or Gemfile.lock
- Changing Rails configuration files (config/*.rb)
- Modifying initializers (config/initializers/*.rb)
- Changing RSpec/test setup configuration
- Altering database.yml or storage.yml

### Migration Data Types

- **Always use `text` for string fields**, never `string`/`varchar` - PostgreSQL handles `text` efficiently and avoids arbitrary length limits
- Use `datetime` instead of `timestamp` for consistency
- **Boolean nullability**: Consider whether booleans need three states (true/false/unknown). Only add `null: false, default: false` when you truly need a two-state field

```ruby
# Good
create_table :articles do |t|
  t.text :title, null: false        # Not string!
  t.text :content
  t.boolean :published              # Nullable - pending/true/false states
  t.boolean :archived, default: false, null: false  # Only when truly binary
end
```

### Controller URL/Redirect Patterns

Use hash notation for same-controller actions - cleaner and more maintainable:

```ruby
# Good - hash notation for same controller
redirect_to({ action: :index })
redirect_to({ action: :show, id: @user.id })
url_for(action: "edit")

# Also acceptable - named routes
redirect_to users_path
```

### I18n Best Practices

```ruby
# Prefer relative keys in views (shorter, auto-scoped)
t(".title")                    # Good - relative to view path
t(".submit_button")            # Good
t("admin.users.index.title")   # Avoid - verbose absolute path

# Use _md suffix for Markdown content
# config/locales/de.yml
de:
  pages:
    about:
      intro_md: |
        ## Willkommen
        Dies ist **Markdown** Inhalt.

# In views, Markdown keys auto-render to HTML
= t(".intro_md")  # Returns safe HTML
```

### Testing Refinements

#### Multiple Assertions Per Example
Multiple assertions in a single example are acceptable when testing related behavior:

```ruby
it "creates a user with correct attributes" do
  result = described_class.new(valid_params).call

  expect(result).to be_success
  expect(result.value.email).to eq("test@example.com")
  expect(result.value.name).to eq("Test User")
end
```

#### Prefer Real Objects Over Mocks
Use `instance_double` only for external APIs - prefer real objects for internal code:

```ruby
# Good - real objects
let(:user) { create(:user) }
let(:service) { described_class.new(user) }

# Only for external APIs
let(:aws_client) { instance_double(Aws::Rekognition::Client) }
```

#### Use css_id Helper in System Specs
Avoid string interpolation for DOM IDs:

```ruby
# Good - use css_id helper
find(css_id(@user))
within(css_id(@media_item)) do
  click_button "Delete"
end

# Bad - string interpolation
find("#user_#{@user.id}")
within("#media_item_#{@media_item.id}") do
```

#### Use Capybara Async Matchers
Avoid flaky `find` assertions - use async matchers instead:

```ruby
# Good - async matchers (waits for condition)
expect(page).to have_content("Success")
expect(page).to have_css(".alert-success")
expect(page).to have_selector("[data-testid='user-card']")

# Bad - flaky find assertions
expect(find(".message").text).to eq("Success")
```

#### Skip Declarative Configuration Testing
Don't test Rails framework behavior - focus on custom logic:

```ruby
# Skip - just tests Rails works
it { should validate_presence_of(:email) }  # Only test if custom behavior

# Good - test violation cases with custom messages
it "requires email with custom message" do
  user = build(:user, email: nil)
  expect(user).not_to be_valid
  expect(user.errors[:email]).to include("wird benötigt")
end
```

### don't do this

* api (json) endpoints
