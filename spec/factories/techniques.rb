# == Schema Information
#
# Table name: techniques
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
#  index_techniques_on_name      (name) UNIQUE
#  index_techniques_on_position  (position)
#  index_techniques_on_slug      (slug) UNIQUE
#
FactoryBot.define do
  factory :technique do
    sequence(:name) { |n| "Technik #{n}" }
    position { 0 }

    trait :oil_on_canvas do
      name { "Öl auf Leinwand" }
    end

    trait :watercolor do
      name { "Aquarell" }
    end

    trait :photography do
      name { "Fotografie" }
    end
  end
end
