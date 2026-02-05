source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"
# Use HAML for views [https://github.com/haml/haml-rails]
gem "haml-rails", "~> 3.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Authorization [https://github.com/CanCanCommunity/cancancan]
gem "cancancan", "~> 3.6"

# Pagination [https://github.com/mislav/will_paginate]
gem "will_paginate", "~> 4.0"
gem "will_paginate-bootstrap-style"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# EXIF metadata extraction [https://github.com/janfri/mini_exiftool]
gem "mini_exiftool", "~> 2.11"

gem "exception_notification", "~> 5.0"

# Background job processing [https://github.com/sidekiq/sidekiq]
gem "sidekiq", "~> 7.3"

# ZIP file processing for bulk imports [https://github.com/rubyzip/rubyzip]
gem "rubyzip", "~> 2.3"

# CSV processing (standard library until Ruby 3.4)
gem "csv"
group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Load environment variables from .env files [https://github.com/bkeepers/dotenv]
  gem "dotenv-rails"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
  gem "factory_bot_rails"
  # Faker for generating test data
  gem "faker"
  gem "rubocop-rails", "~> 2.34"
  gem "rubocop-performance", "~> 1.26"
  gem "rubocop-rspec", "~> 3.9"
  gem "rubocop-capybara", "~> 2.22"

  gem "simplecov", "~> 0.22.0", require: false
  gem "annotaterb", "~> 4.20"
  gem "pry-nav", "~> 1.0"
end

group :test do
  gem "rspec-rails", "~> 8.0"
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 6.0"
  gem "super_diff", "~> 0.18.0"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Convert ERB templates to HAML [https://github.com/haml/html2haml]
  gem "html2haml", require: false
end
