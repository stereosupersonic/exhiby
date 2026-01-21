# Exhiby Project Roadmap

## Vision

Replace the legacy Joomla installation at onlinemuseum-wartenberg.de with a modern Rails-based digital museum content management system.

## Project Phases

### Phase 1: Foundation 🟢
Core infrastructure and basic content management.

| Feature | Status | Priority | Description |
|---------|--------|----------|-------------|
| Authentication | 🟢 | P0 | User authentication with roles (admin, editor, user) via Rails 8 built-in auth |
| Authorization | 🟢 | P0 | Role-based access control with CanCanCan (admin, editor, user roles) |
| Articles | 🟢 | P1 | Press reports with rich text editor (ActionText), cover images, slugs |
| Admin Backend | 🟢 | P0 | Admin dashboard with statistics, navigation, user management |
| i18n (German) | 🟢 | P0 | German as default language |

### Phase 2: Asset Management 🟢
Digital asset handling and organization.

| Feature | Status | Priority | Description |
|---------|--------|----------|-------------|
| Assets (MediaItems) | 🟢 | P0 | Image/video/PDF upload with Active Storage, metadata, thumbnails |
| Publishing Workflow | 🟢 | P0 | Draft → Pending Review → Published workflow with timestamps |
| Tagging System | 🟢 | P1 | Dynamic tags with counter cache, filtering, search |
| Techniques | 🟢 | P1 | Art techniques catalog with position ordering |
| Collections | 🟢 | P1 | Collections with categories, ordered items, cover images |
| Collection Categories | 🟢 | P1 | Hierarchical organization for collections |
| EXIF Metadata Extraction | 🔴 | P1 | Extract and store metadata (date, camera, GPS, etc.) from uploaded images |
| Duplicate Detection | 🔴 | P2 | Detect duplicate images using ruby-vips |
| AI Tagging | 🔴 | P2 | AWS Rekognition for auto-tagging |

### Phase 3: Content Publishing 🟢
Public-facing content features.

| Feature | Status | Priority | Description |
|---------|--------|----------|-------------|
| Artists | 🟢 | P1 | Artist profiles with biography, CV, life dates, media items |
| Public Artist Directory | 🟢 | P1 | Alphabetical artist listing with profile pages |
| Public Collections | 🟢 | P1 | "Land und Leute" collections organized by category |
| Static Pages | 🟢 | P1 | Impressum, Datenschutz, Team pages |
| QR Code for Collections | 🔴 | P1 | Generate QR codes for collections for physical museum displays |
| Foto of the Day | 🔴 | P2 | Daily featured image with automatic rotation |
| Exhibitions | 🟡 | P2 | Virtual exhibitions (placeholder exists) |

### Phase 4: Community Features 🟡
User engagement and contributions.

| Feature | Status | Priority | Description |
|---------|--------|----------|-------------|
| Search | 🟢 | P2 | Full-text search across media items, articles, collections, artists |
| Guest Uploads | 🔴 | P1 | Public photo upload without registration, approval workflow, release management |
| Archive | 🔴 | P3 | Historical archive browsing |

### Phase 5: Migration & Launch 🔴
Data migration and production deployment.

| Feature | Status | Priority | Description |
|---------|--------|----------|-------------|
| Data Migration | 🔴 | P0 | Import from Joomla |
| SEO | 🔴 | P1 | Meta tags, sitemap, structured data |
| Performance | 🔴 | P2 | Caching, CDN, optimization |

## Status Legend

- 🔴 Not Started
- 🟡 In Progress
- 🟢 Completed

## Priority Legend

- **P0**: Critical - Must have for MVP
- **P1**: High - Important for launch
- **P2**: Medium - Nice to have
- **P3**: Low - Future enhancement

## Current Architecture

### Models (14 total)
- **User** - Authentication with roles, session tracking
- **Session** - User session management (IP, user agent)
- **MediaItem** - Core asset (image/video/PDF) with workflow states
- **Article** - Blog/press reports with ActionText
- **Artist** - Artist profiles with biography, CV, life dates
- **Collection** - Asset collections with ordered items
- **CollectionCategory** - Hierarchical collection organization
- **CollectionItem** - Join table for collection ordering
- **MediaTag** - Tagging system with counter cache
- **MediaTagging** - Media item ↔ tag associations
- **Technique** - Art techniques catalog
- **Ability** - CanCanCan authorization rules

### Controllers
**Public (7):** Welcome, Sessions, Articles, Artists, Collections, Search, Passwords

**Admin (11):** Dashboard, MediaItems, Articles, Artists, Collections, CollectionCategories, MediaTags, Techniques, Users, Profiles

### Architecture Opportunities

The following enhancements align with CLAUDE.md patterns:

1. **Service Objects** - Extract complex business logic from controllers
   - MediaItem publishing workflow
   - Collection item management
   - Search coordination

2. **Presenters** - View-specific formatting logic
   - Artist life dates display
   - Media item metadata formatting
   - Collection item ordering

3. **Background Jobs** - Async processing
   - Image variant generation
   - Thumbnail creation
   - Future: AI tagging, duplicate detection

## Implementation Notes

- All features should follow the patterns established in CLAUDE.md
- German UI text via i18n (default locale: de)
- Use data-testid attributes for test selectors
- Rich text editing via ActionText (Lexxy-style)
- Admin backend under `/admin` namespace
- CanCanCan authorization with admin/editor/user roles
- Active Storage for file uploads with variants
- Will_paginate for list pagination
