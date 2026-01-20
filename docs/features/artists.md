# Feature: Artist Profiles

## Status: 🔴 Not Started
## Priority: P1
## Phase: 3 - Content Publishing

---

## Overview

Manage profiles for artists (Kunstschaffende) featured in the museum. Each artist has a profile page with biography, works, and related information.

## User Stories

### As an Admin
- [ ] I want to create artist profiles with biography
- [ ] I want to upload a portrait photo for each artist
- [ ] I want to link assets/artworks to an artist
- [ ] I want to add birth/death dates and locations
- [ ] I want to categorize artists by type (painter, sculptor, etc.)
- [ ] I want to publish/unpublish artist profiles

### As an Editor
- [ ] I want to edit artist information
- [ ] I want to link newly uploaded assets to existing artists

### As a Public User
- [ ] I want to browse all artists alphabetically
- [ ] I want to filter artists by category
- [ ] I want to view an artist's profile and works
- [ ] I want to see related artists

## Requirements

### Functional Requirements

1. **Artist Profile**
   - Name (first, last, display name)
   - Biography (rich text)
   - Portrait image
   - Birth date/place
   - Death date/place (if applicable)
   - Nationality
   - Category/Type (painter, sculptor, photographer, etc.)
   - External links (website, Wikipedia)

2. **Artwork Association**
   - Link assets to artist as creator
   - Display artist's works on profile
   - Show artist info on artwork pages

3. **Public Browsing**
   - Alphabetical artist listing
   - Filter by category
   - Search by name
   - Artist detail page with gallery

### Non-Functional Requirements

- SEO: Structured data for artists (schema.org)
- Accessibility: Proper heading structure

## Data Model

### New Models

```
Artist
├── id: bigint (PK)
├── first_name: string
├── last_name: string (required)
├── display_name: string
├── slug: string (required, unique)
├── biography: rich_text (ActionText)
├── birth_date: date
├── birth_place: string
├── death_date: date
├── death_place: string
├── nationality: string
├── category: string
├── website_url: string
├── wikipedia_url: string
├── status: string (draft, published)
├── portrait_asset_id: bigint (FK -> assets, nullable)
├── created_at: datetime
└── updated_at: datetime
```

### Model Relationships

- Artist has_many Assets (as creator)
- Artist has_one Portrait (Asset reference)
- Asset belongs_to Artist (optional)

## UI/UX

### Admin Interface

**Artist List**
- Sortable table with search
- Quick status toggle
- Artwork count

**Artist Form**
- Personal information section
- Biography rich text editor
- Portrait upload/selector
- Category selector
- External links

### Public Interface

- Grid of artist cards with portraits
- Alphabetical navigation (A-Z)
- Artist detail page:
  - Portrait and bio
  - Gallery of works
  - Timeline (optional)

## Technical Considerations

### Dependencies

- ActionText for biography (already installed)

### Integration Points

- Assets feature (link artworks to artists)
- Navigation ("Kunstschaffende" menu item)
- Search feature (include artists)

## Open Questions

- [ ] What artist categories exist in the original site?
- [ ] Should we support multiple artists per artwork?
- [ ] Do we need artist relationships (teacher/student, influences)?

## References

- Original "Kunstschaffende" section: https://www.onlinemuseum-wartenberg.de/

---

## Implementation Notes

*To be added during implementation*
