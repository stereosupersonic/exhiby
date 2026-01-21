# == Schema Information
#
# Table name: media_taggings
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  media_item_id :bigint           not null
#  media_tag_id  :bigint           not null
#
FactoryBot.define do
  factory :media_tagging do
    association :media_item
    association :media_tag
  end
end
