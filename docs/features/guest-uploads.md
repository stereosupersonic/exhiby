# Feature: Guest Uploads

## Status: 🔴 Not Started
## Priority: P2
## Phase: 4 - Community Features

---

## Overview

Allow public visitors to contribute images and documents to the museum archive with an approval workflow. Submitted content is reviewed by editors before being published.

## User Stories

### As an Admin
- [ ] I want to review all pending guest submissions
- [ ] I want to approve or reject submissions
- [ ] I want to edit submission metadata before approval
- [ ] I want to contact submitters (optional)
- [ ] I want to configure upload settings (max size, types)

### As an Editor
- [ ] I want to review submissions in my area
- [ ] I want to add submissions to collections after approval

### As a Public User (Guest)
- [ ] I want to upload images/documents without registering
- [ ] I want to provide context about my submission
- [ ] I want to include my contact information
- [ ] I want to receive confirmation of my submission
- [ ] I want to agree to terms/copyright release

## Requirements

### Functional Requirements

1. **Submission Form**
   - File upload (images, documents)
   - Title and description
   - Date/era information
   - Source/provenance
   - Submitter name and email
   - Optional: Phone number
   - Copyright/release agreement checkbox
   - CAPTCHA or honeypot spam protection

2. **Approval Workflow**
   - Status: pending, approved, rejected
   - Review queue for admins/editors
   - Approve: Create asset from submission
   - Reject: With optional reason message
   - Request more info (optional)

3. **Notifications**
   - Email confirmation to submitter
   - Email notification to admins on new submission
   - Email to submitter on approval/rejection

### Non-Functional Requirements

- Security: File type validation, virus scanning (optional)
- Privacy: GDPR-compliant data handling
- Spam Prevention: CAPTCHA or honeypot

## Data Model

### New Models

```
GuestSubmission
├── id: bigint (PK)
├── status: string (pending, approved, rejected)
├── title: string (required)
├── description: text
├── date_info: string (approximate date/era)
├── source_info: text
├── submitter_name: string (required)
├── submitter_email: string (required)
├── submitter_phone: string
├── copyright_agreed: boolean (required, true)
├── admin_notes: text
├── rejection_reason: text
├── reviewed_by_id: bigint (FK -> users, nullable)
├── reviewed_at: datetime
├── approved_asset_id: bigint (FK -> assets, nullable)
├── created_at: datetime
└── updated_at: datetime
└── has_one_attached :file
```

### Model Relationships

- GuestSubmission has_one_attached :file
- GuestSubmission belongs_to Reviewer (User, optional)
- GuestSubmission has_one Asset (after approval)

## UI/UX

### Public Interface

**Upload Form**
- Clear instructions
- File drag & drop
- Metadata fields
- Contact information
- Terms agreement
- Submit button

**Confirmation Page**
- Thank you message
- What happens next
- Reference number (optional)

### Admin Interface

**Review Queue**
- List of pending submissions
- Filter by status
- Preview submission
- Quick approve/reject buttons

**Submission Detail**
- Full size file preview
- Submitter information
- Metadata provided
- Approve/Reject actions
- Admin notes field

## Technical Considerations

### Dependencies

```ruby
# Spam protection options
gem "invisible_captcha"  # Honeypot
# or
gem "recaptcha"  # Google reCAPTCHA
```

### Email Templates

- `GuestSubmissionMailer#confirmation` - To submitter
- `GuestSubmissionMailer#new_submission` - To admins
- `GuestSubmissionMailer#approved` - To submitter
- `GuestSubmissionMailer#rejected` - To submitter

### File Handling

- Separate storage for pending submissions
- Move to main storage on approval
- Delete files on rejection (after retention period)

### Integration Points

- Assets feature (create asset on approval)
- Email/Action Mailer
- Admin notifications

## Open Questions

- [ ] Do we need email verification for submitters?
- [ ] What file types should we accept?
- [ ] Maximum file size for guest uploads?
- [ ] Data retention policy for rejected submissions?
- [ ] Do we need a terms of use page?

## References

- GDPR requirements for data collection
- Similar museum contribution systems

---

## Implementation Notes

*To be added during implementation*
