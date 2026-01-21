# == Schema Information
#
# Table name: artists
#
#  id            :bigint           not null, primary key
#  birth_date    :date
#  birth_place   :string
#  death_date    :date
#  death_place   :string
#  name          :string           not null
#  published_at  :datetime
#  slug          :string           not null
#  status        :string           default("draft"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint           not null
#
FactoryBot.define do
  factory :artist do
    sequence(:name) { |n| "Test Artist #{n}" }
    status { "draft" }
    association :created_by, factory: :user

    trait :published do
      status { "published" }
      published_at { 1.day.ago }
    end

    trait :with_dates do
      birth_date { Date.new(1876, 3, 15) }
      birth_place { "Hannover" }
      death_date { Date.new(1945, 8, 20) }
      death_place { "Wartenberg" }
    end

    trait :with_profile_image do
      after(:build) do |artist|
        artist.profile_image.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/test_image.png")),
          filename: "test_profile.png",
          content_type: "image/png"
        )
      end
    end

    trait :with_biography do
      biography { "<p>This is a test biography with <strong>rich text</strong> content.</p>" }
    end

    trait :with_cv do
      cv { "<p>1876 - Born in Hannover<br>1900 - First exhibition<br>1945 - Passed away</p>" }
    end
  end
end
