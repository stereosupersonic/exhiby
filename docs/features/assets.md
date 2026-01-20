# Feature: Asset Management

## Status: 🔴 Not Started
## Priority: P0
## Phase: 2 - Asset Management

---

## Overview

Central asset management system for images, videos, and PDFs. This is the core feature of the museum platform, allowing administrators and editors to upload, organize, and manage digital assets.

## User Stories

### As an Admin
- [ ] I want to upload images (JPG, PNG, WebP, TIFF) to the system
- [ ] I want to upload videos (MP4, WebM)
- [ ] I want to upload PDFs for documents and publications
- [ ] I want to bulk upload multiple files at once
- [ ] I want to see upload progress for large files
- [ ] I want to edit asset metadata (title, description, date, source)
- [ ] I want to delete assets (with confirmation)
- [ ] I want to view all assets in a searchable/filterable list
- [ ] I want to see asset usage (where it's referenced)

### As an Editor
- [ ] I want to upload and manage assets I'm responsible for
- [ ] I want to add assets to articles and pages
- [ ] I want to browse existing assets to reuse them

### As a Public User
- [ ] I want to view high-quality images in a lightbox
- [ ] I want to see image metadata (artist, date, technique)
- [ ] I want to download images in different sizes (optional)

## Requirements

### Functional Requirements

1. **File Upload**
   - Support for images: JPG, PNG, WebP, TIFF, GIF
   - Support for videos: MP4, WebM
   - Support for documents: PDF
   - Maximum file size: configurable (default 50MB for images, 500MB for videos)
   - Drag & drop upload interface
   - Bulk upload support
   - Upload progress indication

2. **Image Processing**
   - Automatic thumbnail generation (multiple sizes)
   - Image variants: thumbnail, medium, large, original
   - WebP conversion for web display
   - EXIF data extraction and storage
   - Orientation correction

3. **Metadata Management**
   - Title (required)
   - Description (rich text)
   - Date/Year of creation
   - Artist/Creator reference
   - Source/Provenance
   - Technique/Medium
   - Dimensions
   - Tags/Keywords
   - Copyright information
   - License type

4. **Asset Organization**
   - List view with filters (type, date, tags)
   - Grid view for visual browsing
   - Search by title, description, tags
   - Sorting options (date, title, type)
   - Pagination

### Non-Functional Requirements

- Performance: Thumbnail loading < 200ms
- Storage: Use Active Storage with S3/local disk
- Security: Only authorized users can upload/edit
- Accessibility: Alt text required for images

## Data Model

### New Models

```
Asset
├── id: bigint (PK)
├── title: string (required)
├── description: text
├── asset_type: string (image, video, document)
├── original_filename: string
├── content_type: string
├── byte_size: bigint
├── metadata: jsonb (EXIF, dimensions, etc.)
├── year: integer
├── source: string
├── technique: string
├── copyright_info: string
├── license: string
├── uploaded_by_id: bigint (FK -> users)
├── created_at: datetime
├── updated_at: datetime
└── has_one_attached :file
    has_many_attached :variants

AssetTag
├── id: bigint (PK)
├── name: string (required, unique)
├── slug: string (required, unique)
└── assets_count: integer (counter cache)

AssetTagging (join table)
├── asset_id: bigint (FK)
└── tag_id: bigint (FK)
```

### Model Relationships

- Asset belongs_to User (uploaded_by)
- Asset has_and_belongs_to_many AssetTag
- Asset has_one_attached :file (Active Storage)
- Asset has_many Collections (through CollectionAsset)

## UI/UX

### Admin Interface

**List View (Index)**
- Toggle between grid/list view
- Filters sidebar: type, date range, tags
- Search bar
- Bulk actions: delete, add to collection, tag
- Quick preview on hover

**Upload View**
- Drag & drop zone
- File browser button
- Upload queue with progress
- Inline metadata editing during upload

**Detail/Edit View**
- Large preview
- Metadata form
- Tag management
- Usage information (where referenced)
- Delete action

### Public Interface

- Lightbox gallery view
- Image zoom capability
- Metadata display panel
- Navigation between images

## Technical Considerations

### Dependencies

```ruby
# Already installed
gem "image_processing", "~> 1.2"

# May need
gem "ruby-vips"  # For image processing
gem "streamio-ffmpeg"  # For video thumbnails (optional)
```

### Active Storage Configuration

```ruby
# config/storage.yml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: eu-central-1
  bucket: exhiby-assets
```

### Image Variants

```ruby
# Suggested variant sizes
VARIANTS = {
  thumbnail: { resize_to_limit: [200, 200] },
  medium: { resize_to_limit: [800, 800] },
  large: { resize_to_limit: [1600, 1600] },
  gallery: { resize_to_fill: [400, 300] }
}
```

### Integration Points

- Collections feature (assets belong to collections)
- Articles feature (embed assets in rich text)
- Artists feature (link assets to artists)
- AI Tagging feature (auto-tag uploaded images)
- Duplicate Detection feature (check on upload)

## Open Questions

- [ ] Should we support video streaming or just download?
- [ ] What are the exact image size requirements from the original site?
- [ ] Should public users be able to download original files?
- [ ] Do we need watermarking for public images?
- [ ] What's the expected storage volume (GB/TB)?

## References

- Original Joomla implementation: https://www.onlinemuseum-wartenberg.de/
- Active Storage Guide: https://guides.rubyonrails.org/active_storage_overview.html
- ruby-vips documentation: https://github.com/libvips/ruby-vips

---

## Implementation Notes

*To be added during implementation*
