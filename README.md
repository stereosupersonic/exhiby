# Exhiby

A digital museum content management system for [museum-wartenberg.de](https://museum-wartenberg.de), replacing the legacy Joomla installation at onlinemuseum-wartenberg.de.

## Features

- **Content Management**: Articles, pages, and blog posts with rich text editing
- **Asset Management**: Images, videos, and PDFs with organized collections
- **Artist Profiles**: Biographies, CVs, and artwork galleries for local artists
- **Collections**: Curated collections of historical postcards, photographs, and documents
- **User Management**: Role-based access control (Admin, Editor, User)
- **Multi-language Support**: German as default language with i18n support
- **Modern Frontend**: Server-rendered views with Hotwire (Turbo + Stimulus)
- **Admin Backend**: Full-featured administration interface
- **SEO Optimized**: Dynamic meta tags, Open Graph, Twitter Cards, canonical URLs

## Tech Stack

| Category | Technology |
|----------|------------|
| **Backend** | Ruby 3.3.9, Rails 8.1.2 |
| **Database** | PostgreSQL |
| **Frontend** | Hotwire (Turbo + Stimulus), Bootstrap 5.3 |
| **Background Jobs** | Sidekiq |
| **Caching** | Redis |
| **Authentication** | Rails 8 built-in (bcrypt) |
| **Authorization** | CanCanCan |
| **Testing** | RSpec |
| **Deployment** | Kamal + Docker |

## Prerequisites

- Ruby 3.3.9 (see `.ruby-version`)
- Node 20.18.1 (see `.node-version`)
- PostgreSQL
- Yarn
- Redis (for caching and background jobs)

## Development Setup

### Native Setup

```bash
# Install dependencies and create database
bin/setup

# Start development server with CSS watch
bin/dev

# Or start Rails server only
bin/rails server
```

### Docker Setup

```bash
# Start all services
docker compose up -d

# Setup database
docker compose exec app bin/rails db:setup

# Rails console
docker compose exec app bin/rails c

# Tail logs
docker compose logs -f app

# Stop all services
docker compose down
```

## Running Tests

```bash
# Run all specs
bin/rspec

# Run specific specs
bin/rspec spec/models
bin/rspec spec/services
bin/rspec spec/system
```

## Code Quality

```bash
# Run linter
bin/rubocop

# Run security scanner
bin/brakeman

# Check for vulnerable gems
bin/bundler-audit
```

## SEO

The application includes comprehensive SEO support:

### Meta Tags
- **Dynamic titles**: Each page has a unique, descriptive title (30-60 chars)
- **Meta descriptions**: Page-specific descriptions (120-160 chars)
- **Canonical URLs**: Prevents duplicate content issues
- **Robots meta**: Controls search engine indexing

### Social Sharing
- **Open Graph tags**: Optimized sharing on Facebook, LinkedIn
- **Twitter Cards**: Rich previews on Twitter/X
- **Dynamic images**: Articles and profiles use their cover images for social sharing

### Implementation

Set page-specific SEO in views using `content_for`:

```haml
- content_for :title, "Page Title"
- content_for :meta_description, "Page description here"
- content_for :og_image, url_for(@article.cover_image)
```

SEO translations are managed in `config/locales/de.yml` under the `seo` key.

## Project Structure

```
app/
├── controllers/           # Thin controllers delegating to services
├── models/                # ActiveRecord models with validations
├── services/              # Business logic and complex operations
├── presenters/            # View-specific logic and formatting
├── helpers/               # View helpers including SEO helpers
├── views/                 # HAML templates
├── javascript/
│   └── controllers/       # Stimulus controllers
└── jobs/                  # Background jobs (Sidekiq)
```

## User Roles

| Role | Permissions |
|------|-------------|
| **Admin** | Full access to all features |
| **Editor** | Manage articles and content |
| **User** | View content, manage own profile |

## Deployment

Deployment uses Kamal with Docker:

```bash
# Deploy to production
bin/kamal deploy

# Rails console on server
bin/kamal console

# Tail production logs
bin/kamal logs

# SSH into container
bin/kamal shell
```

## Environment Variables

### Development

Use `.env` files for local development (gitignored):
- `.env` - Default development variables
- `.env.test` - Test environment overrides
- `.env.local` - Machine-specific overrides

### Production

| Variable | Description |
|----------|-------------|
| `RAILS_MASTER_KEY` | Credentials decryption key |
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis connection string |
| `WEB_CONCURRENCY` | Puma worker count |


## Website Audit

Run a comprehensive website audit using [squirrelscan](https://squirrelscan.com):

```bash
# Install squirrel CLI (if not already installed)
curl -fsSL https://squirrelscan.com/install | bash

# Initialize project (creates squirrel.toml)
squirrel init --project-name museum-wartenberg

# Run audit on production site
squirrel audit https://museum-wartenberg.de --format llm
```

The audit checks 140+ rules including:
- SEO (meta tags, titles, descriptions, canonical URLs)
- Performance (page speed, image optimization, CSS/JS size)
- Accessibility (ARIA labels, heading hierarchy, form labels)
- Security (HTTPS, HSTS, leaked secrets detection)
- Content (heading structure, thin content, keyword stuffing)


## Contributing

1. Create a feature branch from `master`
2. Write tests for new functionality
3. Ensure all tests pass (`bin/rspec`)
4. Ensure code quality checks pass (`bin/rubocop`, `bin/brakeman`)
5. Create a pull request with clear description

## License

MIT License - see [LICENSE](LICENSE) for details.
