# == Schema Information
#
# Table name: media_items
#
#  id               :bigint           not null, primary key
#  copyright        :string
#  description      :text
#  exif_metadata    :jsonb
#  license          :string
#  media_type       :string           not null
#  published_at     :datetime
#  reviewed_at      :datetime
#  source           :string
#  status           :string           default("draft"), not null
#  submitted_at     :datetime
#  technique_legacy :string
#  title            :string           not null
#  year             :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  artist_id        :bigint
#  bulk_import_id   :bigint
#  reviewed_by_id   :bigint
#  technique_id     :bigint
#  uploaded_by_id   :bigint           not null
#
# Indexes
#
#  index_media_items_on_artist_id       (artist_id)
#  index_media_items_on_bulk_import_id  (bulk_import_id)
#  index_media_items_on_media_type      (media_type)
#  index_media_items_on_published_at    (published_at)
#  index_media_items_on_reviewed_by_id  (reviewed_by_id)
#  index_media_items_on_status          (status)
#  index_media_items_on_technique_id    (technique_id)
#  index_media_items_on_uploaded_by_id  (uploaded_by_id)
#  index_media_items_on_year            (year)
#
# Foreign Keys
#
#  fk_rails_...  (artist_id => artists.id) ON DELETE => restrict
#  fk_rails_...  (bulk_import_id => bulk_imports.id)
#  fk_rails_...  (reviewed_by_id => users.id)
#  fk_rails_...  (technique_id => techniques.id)
#  fk_rails_...  (uploaded_by_id => users.id)
#
FactoryBot.define do
  factory :media_item do
    sequence(:title) { |n| "Test Media Item #{n}" }
    description { "This is a test media item description." }
    media_type { "image" }
    status { "draft" }
    association :uploaded_by, factory: :user

    after(:build) do |media_item|
      media_item.file.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test_image.png")),
        filename: "test_image.png",
        content_type: "image/png"
      )
    end

    trait :published do
      status { "published" }
      published_at { 1.day.ago }
      association :reviewed_by, factory: :user
      reviewed_at { 1.day.ago }
    end

    trait :pending_review do
      status { "pending_review" }
      submitted_at { 1.hour.ago }
    end

    trait :video do
      media_type { "video" }
      after(:build) do |media_item|
        media_item.file.detach
        media_item.file.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/test_video.mp4")),
          filename: "test_video.mp4",
          content_type: "video/mp4"
        )
      end
    end

    trait :pdf do
      media_type { "pdf" }
      after(:build) do |media_item|
        media_item.file.detach
        media_item.file.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/test_document.pdf")),
          filename: "test_document.pdf",
          content_type: "application/pdf"
        )
      end
    end

    trait :with_metadata do
      year { 2020 }
      source { "Museum Archive" }
      association :technique
      copyright { "Museum Wartenberg" }
      license { "CC BY-NC 4.0" }
    end

    trait :with_file do
      # File is already attached by default in after(:build)
      # This trait exists for explicit reference in other factories
    end
  end
end
