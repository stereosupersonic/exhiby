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

## Tech Stack

- **Ruby**: 3.3.9
- **Rails**: 8.1.2
- **Database**: PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus), Bootstrap 5.3.8
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **Testing**: RSpec
- **Deployment**: Kamal + Docker

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

## Code Conventions

### Views

- **Use HAML** for all templates (add `haml-rails` gem)
- Use Bootstrap 5 components and utilities
- Keep views simple - extract complex logic to presenters
- Use `data-testid` attributes for test selectors

### Services

Place in `app/services/` with verb + noun naming:

```ruby
# app/services/images/process_upload.rb
module Images
  class ProcessUpload < BaseService
    def call
      # Business logic here
    end
  end
end
```

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

### Background Jobs

- Use Solid Queue (configured in Puma)
- Place jobs in `app/jobs/` organized by domain
- Keep jobs idempotent

```ruby
# app/jobs/images/generate_thumbnails_job.rb
module Images
  class GenerateThumbnailsJob < ApplicationJob
    queue_as :images

    def perform(image_id)
      image = Image.find(image_id)
      Images::GenerateThumbnails.new(image).call
    end
  end
end
```

### JavaScript

- Use Stimulus for interactivity
- Minimize custom JavaScript
- Place controllers in `app/javascript/controllers/`
- Use Turbo for navigation and form submissions

### CSS

- Bootstrap 5 is the primary framework
- Custom styles go in `app/assets/stylesheets/`
- Use Bootstrap utilities before writing custom CSS
- Run `yarn build:css` to compile changes

## Database

- Always add indexes for foreign keys
- Use database constraints, not just validations
- Name migrations descriptively: `add_artist_to_images`
- Use `references` with `foreign_key: true`

## Testing

- Use RSpec for all tests
- Use FactoryBot for test data
- Use Capybara for system specs (headless Chrome)
- Test services thoroughly
- System specs for critical user flows
- Mock external services (AWS Rekognition, etc.)

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
