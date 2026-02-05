# == Schema Information
#
# Table name: bulk_imports
#
#  id                 :bigint           not null, primary key
#  completed_at       :datetime
#  error_messages     :jsonb            not null
#  failed_imports     :integer          default(0), not null
#  import_log         :jsonb            not null
#  import_type        :string           default("zip"), not null
#  processed_files    :integer          default(0), not null
#  started_at         :datetime
#  status             :string           default("pending"), not null
#  successful_imports :integer          default(0), not null
#  total_files        :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_id      :bigint           not null
#
# Indexes
#
#  index_bulk_imports_on_created_at     (created_at)
#  index_bulk_imports_on_created_by_id  (created_by_id)
#  index_bulk_imports_on_import_type    (import_type)
#  index_bulk_imports_on_status         (status)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#
FactoryBot.define do
  factory :bulk_import do
    association :created_by, factory: :user
    import_type { "zip" }
    status { "pending" }
    total_files { 0 }
    processed_files { 0 }
    successful_imports { 0 }
    failed_imports { 0 }
    import_log { [] }
    error_messages { [] }

    after(:build) do |bulk_import|
      bulk_import.file.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test_import.zip")),
        filename: "test_import.zip",
        content_type: "application/zip"
      )
    end

    trait :processing do
      status { "processing" }
      started_at { 1.minute.ago }
      total_files { 5 }
      processed_files { 2 }
      successful_imports { 2 }
    end

    trait :completed do
      status { "completed" }
      started_at { 5.minutes.ago }
      completed_at { 1.minute.ago }
      total_files { 5 }
      processed_files { 5 }
      successful_imports { 4 }
      failed_imports { 1 }
      import_log do
        [
          { filename: "image1.jpg", success: true, media_item_id: 1, attribute_sources: { title: "csv" } },
          { filename: "image2.jpg", success: true, media_item_id: 2, attribute_sources: { title: "exif" } },
          { filename: "image3.jpg", success: true, media_item_id: 3, attribute_sources: { title: "filename" } },
          { filename: "image4.jpg", success: true, media_item_id: 4, attribute_sources: { title: "csv" } },
          { filename: "image5.jpg", success: false, errors: ["Invalid file type"] }
        ]
      end
    end

    trait :failed do
      status { "failed" }
      started_at { 2.minutes.ago }
      completed_at { 1.minute.ago }
      error_messages { ["ZIP file extraction failed"] }
    end
  end
end
