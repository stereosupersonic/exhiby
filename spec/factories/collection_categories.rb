# == Schema Information
#
# Table name: collection_categories
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  position   :integer          default(0), not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_collection_categories_on_name      (name) UNIQUE
#  index_collection_categories_on_position  (position)
#  index_collection_categories_on_slug      (slug) UNIQUE
#
FactoryBot.define do
  factory :collection_category do
    sequence(:name) { |n| "Kategorie #{n}" }
    position { 0 }

    trait :historische_ansichtskarten do
      name { "Historische Ansichtskarten" }
    end

    trait :historische_fotos do
      name { "Historische Fotos" }
    end
  end
end
