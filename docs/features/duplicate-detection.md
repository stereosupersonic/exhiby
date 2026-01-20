# Feature: Duplicate Detection

## Status: 🔴 Not Started
## Priority: P2
## Phase: 2 - Asset Management

---

## Overview

Detect duplicate or similar images during upload using perceptual hashing (pHash) via ruby-vips. Prevents duplicate uploads and helps identify variations of the same image.

## User Stories

### As an Admin
- [ ] I want to be warned when uploading a duplicate image
- [ ] I want to see visually similar images to what I'm uploading
- [ ] I want to choose to proceed anyway or cancel
- [ ] I want to find duplicates in existing assets
- [ ] I want to merge duplicate assets

### As an Editor
- [ ] I want to avoid uploading duplicates accidentally
- [ ] I want to see which existing image matches my upload

## Requirements

### Functional Requirements

1. **Upload Detection**
   - Calculate perceptual hash on upload
   - Compare against existing hashes
   - Show warning with similar images
   - Allow user to proceed or cancel

2. **Similarity Matching**
   - Exact duplicates (100% match)
   - Near duplicates (configurable threshold, e.g., 90%)
   - Show similarity percentage

3. **Duplicate Management**
   - Find all potential duplicates report
   - Merge duplicates (keep one, transfer references)
   - Mark as "intentional duplicate" (variations)

4. **Batch Processing**
   - Analyze existing images
   - Generate missing hashes
   - Background job processing

### Non-Functional Requirements

- Performance: Hash calculation < 500ms per image
- Storage: Hash stored in database for fast lookup
- Accuracy: Low false positive rate

## Data Model

### Schema Changes

```
Assets table additions:
├── phash: string (perceptual hash, 64-bit hex)
├── phash_calculated_at: datetime
└── index on phash for fast lookup

DuplicateGroup (optional, for tracking)
├── id: bigint (PK)
├── primary_asset_id: bigint (FK -> assets)
├── status: string (pending_review, resolved, intentional)
├── created_at: datetime
└── updated_at: datetime

DuplicateGroupMember
├── id: bigint (PK)
├── duplicate_group_id: bigint (FK)
├── asset_id: bigint (FK -> assets)
├── similarity_score: decimal
└── created_at: datetime
```

## UI/UX

### Upload Flow

```
[Select File] → [Calculate Hash] → [Check Duplicates]
                                          ↓
                                    [No Duplicates] → [Continue Upload]
                                          ↓
                                    [Found Similar] → [Show Warning Modal]
                                                            ↓
                                                    [Proceed] or [Cancel]
```

### Warning Modal

```
┌─────────────────────────────────────────────┐
│  ⚠️ Similar Image Found                      │
│                                             │
│  The image you're uploading appears to      │
│  match an existing image.                   │
│                                             │
│  ┌─────────┐  ┌─────────┐                  │
│  │ Upload  │  │ Existing │                  │
│  │ [thumb] │  │ [thumb]  │                  │
│  └─────────┘  └─────────┘                  │
│               95% similar                   │
│                                             │
│  [View Existing]  [Upload Anyway]  [Cancel] │
└─────────────────────────────────────────────┘
```

### Duplicate Report

- List of potential duplicate groups
- Side-by-side comparison
- Merge action
- Mark as intentional

## Technical Considerations

### Dependencies

```ruby
gem "ruby-vips"  # Already in project for image processing
# or
gem "phashion"   # Alternative pHash library
```

### Hash Calculation

```ruby
class PerceptualHashService
  def initialize(image_path)
    @image = Vips::Image.new_from_file(image_path)
  end

  def calculate_phash
    # 1. Resize to 32x32
    # 2. Convert to grayscale
    # 3. Apply DCT (Discrete Cosine Transform)
    # 4. Calculate hash from DCT coefficients
  end

  def self.hamming_distance(hash1, hash2)
    # Compare two hashes
    # Returns number of different bits
  end

  def self.similarity_percentage(hash1, hash2)
    distance = hamming_distance(hash1, hash2)
    ((64 - distance) / 64.0 * 100).round(2)
  end
end
```

### Threshold Configuration

```ruby
# config/settings.yml or environment variables
duplicate_detection:
  exact_match_threshold: 100     # 100% = identical
  similar_threshold: 90          # 90%+ = very similar
  warn_threshold: 80             # 80%+ = show warning
```

### Integration Points

- Assets feature (hook into upload process)
- Background Jobs (batch hash calculation)
- Admin dashboard (duplicate report)

## Open Questions

- [ ] What similarity threshold should trigger a warning?
- [ ] Should we block exact duplicates or just warn?
- [ ] How to handle rotated/cropped versions?
- [ ] Should we compare across different file formats?

## References

- ruby-vips documentation: https://github.com/libvips/ruby-vips
- Perceptual hashing explained: https://www.hackerfactor.com/blog/index.php?/archives/432-Looks-Like.html
- pHash algorithm: https://phash.org/

---

## Implementation Notes

*To be added during implementation*
