# Feature: Articles (Presseberichte)

## Status: 🟢 Completed
## Priority: P1
## Phase: 1 - Foundation

---

## Overview

Create an articles management system with:
- Admin backend for creating/editing articles with rich text editor (Lexxy)
- Public articles listing page
- Recent articles display on start page
- **Internationalization (i18n) with German as default language**

## Prerequisites

**Trix** is the default rich text editor that comes with ActionText in Rails.

## Implementation Steps

### 1. Configure i18n with German as Default

**File**: `config/application.rb`

Add inside `class Application`:
```ruby
config.i18n.default_locale = :de
config.i18n.available_locales = [:de, :en]
config.i18n.fallbacks = [:de, :en]
```

**File**: `config/locales/de.yml`

Contains German translations for:
- Date/time formats (German convention DD.MM.YYYY)
- ActiveRecord models and attributes
- Article statuses
- Admin section labels
- Public articles labels
- Common labels

### 2. Install ActionText

```bash
bin/rails action_text:install
bin/rails db:migrate
```

This will:
- Add Trix and ActionText to importmap
- Create ActionText migrations
- Add the necessary JavaScript imports

### 3. Create Article Model

**Migration**: `db/migrate/YYYYMMDDHHMMSS_create_articles.rb`

```ruby
create_table :articles do |t|
  t.string :title, null: false
  t.string :slug, null: false
  t.string :status, null: false, default: "draft"
  t.datetime :published_at
  t.references :author, null: false, foreign_key: { to_table: :users }
  t.timestamps
end

add_index :articles, :slug, unique: true
add_index :articles, :status
add_index :articles, :published_at
```

**Model**: `app/models/article.rb`

Key features:
- `STATUSES = %w[draft published]`
- `belongs_to :author, class_name: "User"`
- `has_rich_text :content`
- Validations for title, slug, status
- Auto-generated slug from title
- Scopes: `published`, `recent`, `by_publication_date`
- `#status_name` method for translated status
- `#published?` returns true when status is "published" AND (published_at is nil OR published_at <= now)

### 4. Create Admin Namespace

**Files created:**

| File | Purpose |
|------|---------|
| `app/controllers/admin/base_controller.rb` | Admin authorization base |
| `app/controllers/admin/dashboard_controller.rb` | Admin landing page |
| `app/controllers/admin/articles_controller.rb` | Articles CRUD |
| `app/views/layouts/admin.html.haml` | Admin layout with nav |
| `app/views/admin/dashboard/index.html.haml` | Admin dashboard |
| `app/views/admin/articles/index.html.haml` | Articles list |
| `app/views/admin/articles/new.html.haml` | New article form |
| `app/views/admin/articles/edit.html.haml` | Edit article form |
| `app/views/admin/articles/show.html.haml` | Article preview |
| `app/views/admin/articles/_form.html.haml` | Shared form partial |

### 5. Update Routes

**File**: `config/routes.rb`

```ruby
namespace :admin do
  root to: "dashboard#index"
  resources :articles
end

resources :articles, only: [:index, :show], param: :slug
```

### 6. Update Authorization

**File**: `app/models/ability.rb`

Added:
- Public can read published articles: `can :read, Article, status: "published"`
- Admins can manage all (already had `can :manage, :all`)
- Editors can manage admin_area and articles

### 7. Create Public Articles Views

| File | Purpose |
|------|---------|
| `app/controllers/articles_controller.rb` | Public articles display |
| `app/views/articles/index.html.haml` | Articles listing |
| `app/views/articles/show.html.haml` | Single article |

### 8. Integrate with Start Page

**File**: `app/controllers/welcome_controller.rb`

```ruby
def index
  @recent_articles = Article.recent(3)
end
```

**File**: `app/views/welcome/index.html.haml`

Added articles preview section displaying up to 3 recent articles.

### 9. Create Presenter

**Files:**
- `app/presenters/application_presenter.rb` - Base presenter
- `app/presenters/article_presenter.rb` - Article presenter

Presenter methods:
- `formatted_published_at` / `formatted_published_at_short`
- `status_badge_class`
- `status_label`
- `author_name`
- `excerpt(length:)`

## Files Modified

| File | Change |
|------|--------|
| `config/application.rb` | Set default locale to `:de` |
| `config/importmap.rb` | Pinned trix and actiontext |
| `app/javascript/application.js` | Import trix and actiontext |
| `config/routes.rb` | Added admin namespace and public articles routes |
| `app/models/ability.rb` | Added Article and admin_area permissions |
| `app/models/user.rb` | Added `has_many :articles` association |
| `app/controllers/welcome_controller.rb` | Load recent articles |
| `app/views/welcome/index.html.haml` | Display recent articles section + navigation link |

## Files Created

| File | Purpose |
|------|--------|
| `config/locales/de.yml` | German translations |
| `db/migrate/XXX_create_articles.rb` | Articles table |
| `app/models/article.rb` | Article model |
| `app/controllers/admin/base_controller.rb` | Admin base |
| `app/controllers/admin/dashboard_controller.rb` | Admin dashboard |
| `app/controllers/admin/articles_controller.rb` | Admin CRUD |
| `app/controllers/articles_controller.rb` | Public controller |
| `app/views/layouts/admin.html.haml` | Admin layout |
| `app/views/admin/dashboard/index.html.haml` | Admin home |
| `app/views/admin/articles/*.html.haml` | Admin article views |
| `app/views/articles/*.html.haml` | Public article views |
| `app/presenters/application_presenter.rb` | Base presenter |
| `app/presenters/article_presenter.rb` | Article presenter |
| `spec/factories/articles.rb` | Article factory |
| `spec/models/article_spec.rb` | Model specs |
| `spec/presenters/article_presenter_spec.rb` | Presenter specs |
| `spec/requests/admin/articles_spec.rb` | Admin request specs |
| `spec/requests/articles_spec.rb` | Public request specs |
| `spec/system/admin/articles_spec.rb` | Admin system specs |
| `spec/system/articles_spec.rb` | Public articles specs |

## i18n Guidelines

- **Always use `t()` helper** in views instead of hardcoded strings
- **Use `l()` helper** for dates/times with appropriate format
- **Model attribute names** auto-translate via `activerecord.attributes`
- **Flash messages** use i18n keys from `admin.articles.messages`
- **Status labels** use `article.status_name` method for translated status

## Test Coverage

1. **Model specs**: Validations, scopes, slug generation
2. **Presenter specs**: Formatted dates, badge classes, delegation
3. **Request specs**: Admin CRUD authorization, public article access
4. **System specs**:
   - Admin creates/edits/deletes article
   - Public views published articles
   - Start page shows recent articles

## Verification

1. Run migrations: `bin/rails db:migrate`
2. Run tests: `bin/rspec`
3. Run linters: `bin/rubocop && bin/brakeman`
4. Manual testing:
   - Sign in as admin at `/session/new`
   - Navigate to `/admin`
   - Create new article with rich text
   - Publish article
   - View at `/articles` and on start page
   - Verify all UI text is in German

## Notes

- **Trix** is used as the rich text editor (ActionText default)
- **All UI text in German** via i18n - no hardcoded strings
- Use `data-testid` attributes for stable test selectors
- Date formats follow German convention (DD.MM.YYYY)
