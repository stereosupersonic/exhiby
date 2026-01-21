# == Schema Information
#
# Table name: media_tags
#
#  id                :bigint           not null, primary key
#  media_items_count :integer          default(0)
#  name              :string           not null
#  slug              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
FactoryBot.define do
  factory :media_tag do
    sequence(:name) { |n| "Tag #{n}" }

    trait :popular do
      media_items_count { 10 }
    end
  end
end
