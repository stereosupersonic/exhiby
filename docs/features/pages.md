# Feature: Static Pages

## Status: 🔴 Not Started
## Priority: P1
## Phase: 3 - Content Publishing

---

## Overview

Manage static content pages like "About", "Team", "Contact", and other informational pages. Supports rich text content with embedded images.

## User Stories

### As an Admin
- [ ] I want to create and edit static pages
- [ ] I want to use a rich text editor for page content
- [ ] I want to embed images and media in pages
- [ ] I want to set page URLs (slugs)
- [ ] I want to organize pages hierarchically (parent/child)
- [ ] I want to publish/unpublish pages
- [ ] I want to set page position in navigation

### As an Editor
- [ ] I want to edit page content
- [ ] I want to preview pages before publishing

### As a Public User
- [ ] I want to navigate to pages via menu
- [ ] I want to read page content
- [ ] I want to see related pages (if any)

## Requirements

### Functional Requirements

1. **Page Management**
   - Title and URL slug
   - Rich text content (Lexxy)
   - Meta description for SEO
   - Featured image (optional)
   - Publication status
   - Parent page (for hierarchy)
   - Navigation position

2. **Page Hierarchy**
   - Parent/child relationships
   - Breadcrumb navigation
   - Automatic submenu generation

3. **Special Pages**
   - Homepage content management
   - Contact page with form (optional)
   - Team page with member profiles

### Non-Functional Requirements

- SEO: Meta tags, Open Graph
- Performance: Page caching
- Accessibility: Proper semantic HTML

## Data Model

### New Models

```
Page
├── id: bigint (PK)
├── title: string (required)
├── slug: string (required, unique)
├── content: rich_text (ActionText)
├── meta_description: text
├── status: string (draft, published)
├── parent_id: bigint (FK -> pages, nullable)
├── position: integer
├── show_in_navigation: boolean (default: true)
├── featured_asset_id: bigint (FK -> assets, nullable)
├── published_at: datetime
├── created_at: datetime
└── updated_at: datetime
```

### Model Relationships

- Page belongs_to Parent Page (optional, self-referential)
- Page has_many Child Pages
- Page has_one Featured Asset (optional)

## UI/UX

### Admin Interface

**Page List**
- Tree view showing hierarchy
- Status indicators
- Quick reordering

**Page Form**
- Title and slug
- Rich text editor (Lexxy)
- SEO meta fields
- Parent page selector
- Featured image selector
- Navigation toggle

### Public Interface

- Pages rendered with site layout
- Breadcrumb navigation
- Submenu for child pages

## Technical Considerations

### Existing Pages

Currently existing static pages (routes already defined):
- `/impressum` - Impressum
- `/datenschutzerklaerung` - Privacy policy

These should be migrated to the Pages system or kept as special cases.

### Integration Points

- Navigation (dynamic menu from pages)
- Assets (embed in content)
- SEO (meta tags)

## Open Questions

- [ ] Should Impressum/Datenschutz remain hardcoded or be Page entries?
- [ ] Do we need page templates (e.g., team page layout)?
- [ ] Should pages support multiple languages (i18n content)?

## References

- Original Joomla pages: https://www.onlinemuseum-wartenberg.de/

---

## Implementation Notes

*To be added during implementation*
