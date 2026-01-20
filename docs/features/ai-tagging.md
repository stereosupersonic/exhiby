# Feature: AI-Powered Tagging

## Status: 🔴 Not Started
## Priority: P2
## Phase: 2 - Asset Management

---

## Overview

Automatically tag uploaded images using AWS Rekognition for object detection, scene analysis, and text recognition. Helps with asset organization and searchability.

## User Stories

### As an Admin
- [ ] I want uploaded images to be automatically analyzed
- [ ] I want to see suggested tags for each image
- [ ] I want to accept or reject suggested tags
- [ ] I want to configure which types of tags to detect
- [ ] I want to set a minimum confidence threshold
- [ ] I want to manually trigger re-analysis

### As an Editor
- [ ] I want to see AI-suggested tags when editing assets
- [ ] I want to quickly accept all suggested tags
- [ ] I want to remove incorrect tags

### As a Public User
- [ ] I want to search images by detected objects
- [ ] I want to filter images by detected scenes

## Requirements

### Functional Requirements

1. **Automatic Analysis**
   - Trigger on image upload
   - Process in background job
   - Store results with confidence scores
   - German translation of English labels

2. **Detection Types**
   - Object/Label detection (Hund, Katze, Auto, etc.)
   - Scene detection (Landschaft, Innenraum, etc.)
   - Text detection (OCR for signs, documents)
   - Face detection (optional, GDPR considerations)

3. **Tag Management**
   - Suggested tags with confidence scores
   - Accept/reject workflow
   - Bulk accept/reject
   - Manual override

4. **Configuration**
   - Enable/disable per detection type
   - Minimum confidence threshold (default 80%)
   - Maximum tags per image
   - Label translation mapping

### Non-Functional Requirements

- Performance: Background processing, no blocking
- Cost: Optimize API calls (batch processing)
- Privacy: GDPR compliance for face detection
- Reliability: Handle API failures gracefully

## Data Model

### New Models

```
AiAnalysis
├── id: bigint (PK)
├── asset_id: bigint (FK -> assets)
├── provider: string (aws_rekognition)
├── analysis_type: string (labels, text, faces)
├── raw_response: jsonb
├── processed_at: datetime
├── error_message: text (nullable)
├── created_at: datetime
└── updated_at: datetime

AiSuggestedTag
├── id: bigint (PK)
├── ai_analysis_id: bigint (FK)
├── asset_id: bigint (FK -> assets)
├── original_label: string (English)
├── translated_label: string (German)
├── confidence: decimal
├── category: string (object, scene, text)
├── status: string (pending, accepted, rejected)
├── accepted_by_id: bigint (FK -> users, nullable)
├── accepted_at: datetime
└── created_at: datetime
```

### Model Relationships

- Asset has_many AiAnalyses
- Asset has_many AiSuggestedTags
- AiAnalysis belongs_to Asset
- AiAnalysis has_many AiSuggestedTags
- AiSuggestedTag belongs_to AiAnalysis
- AiSuggestedTag belongs_to Asset

## UI/UX

### Admin Interface

**Asset Edit - AI Tags Section**
- List of suggested tags with confidence %
- Checkboxes to accept/reject
- "Accept All" / "Reject All" buttons
- Visual indicator for AI vs manual tags

**Bulk Tagging Queue**
- List of assets with pending suggestions
- Quick accept/reject actions
- Filter by confidence level

**Settings**
- Enable/disable AI tagging
- Confidence threshold slider
- Detection type toggles

### Analysis Flow

```
[Image Upload] → [Background Job] → [AWS Rekognition API]
                                           ↓
[Store Results] ← [Process Response] ← [API Response]
       ↓
[Show in Admin UI] → [User Accepts/Rejects] → [Create Tags]
```

## Technical Considerations

### Dependencies

```ruby
# AWS SDK
gem "aws-sdk-rekognition"
```

### AWS Configuration

```ruby
# config/initializers/aws.rb
Aws.config.update({
  region: Rails.application.credentials.dig(:aws, :region),
  credentials: Aws::Credentials.new(
    Rails.application.credentials.dig(:aws, :access_key_id),
    Rails.application.credentials.dig(:aws, :secret_access_key)
  )
})
```

### Background Job

```ruby
class AnalyzeImageJob < ApplicationJob
  queue_as :ai_analysis

  def perform(asset_id)
    asset = Asset.find(asset_id)
    AiTaggingService.new(asset).analyze
  end
end
```

### Label Translation

```yaml
# config/locales/ai_labels.yml
de:
  ai_labels:
    dog: Hund
    cat: Katze
    car: Auto
    landscape: Landschaft
    portrait: Porträt
    # ... more mappings
```

### Cost Considerations

- AWS Rekognition pricing: ~$1 per 1000 images
- Batch processing to reduce costs
- Cache results to avoid re-analysis
- Only analyze images (not videos initially)

### Integration Points

- Assets feature (trigger on upload)
- Tags feature (create tags from accepted suggestions)
- Search feature (search by AI-detected content)
- Background Jobs (Solid Queue)

## Open Questions

- [ ] Should we use face detection (GDPR implications)?
- [ ] Do we need celebrity recognition?
- [ ] Should we analyze existing images on migration?
- [ ] Budget for AWS Rekognition?
- [ ] Should we support other providers (Google Vision, Azure)?

## References

- AWS Rekognition Documentation: https://docs.aws.amazon.com/rekognition/
- AWS Rekognition Pricing: https://aws.amazon.com/rekognition/pricing/
- GDPR and facial recognition considerations

---

## Implementation Notes

*To be added during implementation*
