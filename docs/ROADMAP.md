# Exhiby Project Roadmap

## Vision

Replace the legacy Joomla installation at onlinemuseum-wartenberg.de with a modern Rails-based digital museum content management system.

## Project Phases

### Phase 1: Foundation 🟡
Core infrastructure and basic content management.

| Feature | Status | Priority | Description |
|---------|--------|----------|-------------|
| Authentication | 🟢 | P0 | User authentication with roles (admin, editor, user) |
| Articles | 🟢 | P1 | Press reports with rich text editor (Lexxy) |
| Admin Backend | 🟢 | P0 | Admin dashboard and navigation |
| i18n (German) | 🟢 | P0 | German as default language |

### Phase 2: Asset Management 🔴
Digital asset handling and organization.

| Feature | Status | Priority | Description |
|---------|--------|----------|-------------|
| Assets | 🔴 | P0 | Image/video/PDF upload and management |
| Collections | 🔴 | P1 | Organize assets into collections/albums |
| Duplicate Detection | 🔴 | P2 | Detect duplicate images using ruby-vips |
| AI Tagging | 🔴 | P2 | AWS Rekognition for auto-tagging |

### Phase 3: Content Publishing 🔴
Public-facing content features.

| Feature | Status | Priority | Description |
|---------|--------|----------|-------------|
| Artists | 🔴 | P1 | Artist profiles and portfolios |
| Pages | 🔴 | P1 | Static pages (About, Team, etc.) |
| Exhibitions | 🔴 | P2 | Virtual exhibitions |
| Image of the Week | 🔴 | P3 | Featured image rotation |

### Phase 4: Community Features 🔴
User engagement and contributions.

| Feature | Status | Priority | Description |
|---------|--------|----------|-------------|
| Guest Uploads | 🔴 | P2 | Public upload with approval workflow |
| Archive | 🔴 | P3 | Historical archive browsing |
| Search | 🔴 | P2 | Full-text search across content |

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

## Implementation Notes

- All features should follow the patterns established in CLAUDE.md
- German UI text via i18n (default locale: de)
- Use data-testid attributes for test selectors
- Rich text editing via Lexxy (ActionText)
- Admin backend under `/admin` namespace
