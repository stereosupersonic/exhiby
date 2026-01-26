# == Schema Information
#
# Table name: collections
#
#  id                     :bigint           not null, primary key
#  name                   :string           not null
#  position               :integer          default(0), not null
#  published_at           :datetime
#  slug                   :string           not null
#  status                 :string           default("draft"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  collection_category_id :bigint           not null
#  cover_media_item_id    :bigint
#  created_by_id          :bigint           not null
#
# Indexes
#
#  index_collections_on_collection_category_id               (collection_category_id)
#  index_collections_on_collection_category_id_and_position  (collection_category_id,position)
#  index_collections_on_cover_media_item_id                  (cover_media_item_id)
#  index_collections_on_created_by_id                        (created_by_id)
#  index_collections_on_published_at                         (published_at)
#  index_collections_on_slug                                 (slug) UNIQUE
#  index_collections_on_status                               (status)
#
# Foreign Keys
#
#  fk_rails_...  (collection_category_id => collection_categories.id)
#  fk_rails_...  (cover_media_item_id => media_items.id)
#  fk_rails_...  (created_by_id => users.id)
#
FactoryBot.define do
  factory :collection do
    sequence(:name) { |n| "Sammlung #{n}" }
    status { "draft" }
    position { 0 }
    association :collection_category
    association :created_by, factory: :user

    trait :published do
      status { "published" }
      published_at { 1.day.ago }
    end

    trait :with_cover_image do
      association :cover_media_item, factory: %i[media_item with_file]
    end

    trait :with_description do
      description { "<p>Dies ist eine Testbeschreibung für die Sammlung.</p>" }
    end

    trait :with_media_items do
      after(:create) do |collection|
        create_list(:collection_item, 3, collection: collection)
      end
    end
  end
end
