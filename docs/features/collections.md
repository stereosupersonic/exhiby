# Feature: Collections & Albums

## Status: 🔴 Not Started
## Priority: P1
## Phase: 2 - Asset Management

---

## Overview

Organize assets into themed collections and albums. Collections group related assets for exhibitions, themes, or organizational purposes. Albums are public-facing galleries.

## User Stories

### As an Admin
- [ ] I want to create collections to organize assets
- [ ] I want to add/remove assets from collections
- [ ] I want to reorder assets within a collection
- [ ] I want to set a cover image for each collection
- [ ] I want to publish/unpublish collections
- [ ] I want to nest collections (subcollections)

### As an Editor
- [ ] I want to manage collections I'm responsible for
- [ ] I want to quickly add assets to collections while browsing

### As a Public User
- [ ] I want to browse published collections
- [ ] I want to view all assets in a collection as a gallery
- [ ] I want to navigate between collections

## Requirements

### Functional Requirements

1. **Collection Management**
   - Create/edit/delete collections
   - Title, description, cover image
   - Publication status (draft/published)
   - Ordering/position
   - Optional: Hierarchical collections (parent/child)

2. **Asset Assignment**
   - Add multiple assets to collection
   - Remove assets from collection
   - Reorder assets within collection
   - An asset can belong to multiple collections

3. **Public Display**
   - Collection listing page
   - Collection detail with gallery view
   - Lightbox navigation within collection

### Non-Functional Requirements

- Performance: Collection page loads < 500ms
- UX: Drag & drop for reordering
- SEO: Proper meta tags for collections

## Data Model

### New Models

```
Collection
├── id: bigint (PK)
├── title: string (required)
├── slug: string (required, unique)
├── description: text
├── status: string (draft, published)
├── position: integer
├── parent_id: bigint (FK -> collections, nullable)
├── cover_asset_id: bigint (FK -> assets, nullable)
├── published_at: datetime
├── created_at: datetime
└── updated_at: datetime

CollectionAsset (join table)
├── id: bigint (PK)
├── collection_id: bigint (FK)
├── asset_id: bigint (FK)
├── position: integer
└── created_at: datetime
```

### Model Relationships

- Collection has_many Assets through CollectionAsset
- Collection belongs_to Cover Asset (optional)
- Collection belongs_to Parent Collection (optional, self-referential)
- Collection has_many Child Collections

## UI/UX

### Admin Interface

**Collection List**
- Tree view for nested collections
- Quick publish/unpublish toggle
- Asset count per collection
- Drag & drop reordering

**Collection Edit**
- Title, slug, description
- Cover image selector
- Asset management (add/remove/reorder)
- Parent collection selector

### Public Interface

- Grid of collection cards with cover images
- Collection detail page with gallery
- Breadcrumb navigation for nested collections

## Technical Considerations

### Dependencies

- Stimulus controller for drag & drop reordering
- acts_as_list gem for positioning (optional)

### Integration Points

- Assets feature (collections contain assets)
- Navigation (link to collections in menu)

## Open Questions

- [ ] How deep can collection nesting go?
- [ ] Should we limit assets per collection?
- [ ] Do we need collection categories/types?

## References

- Original collections on Joomla site: [URL]

---

## Implementation Notes

*To be added during implementation*
