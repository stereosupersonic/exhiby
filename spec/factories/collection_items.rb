# == Schema Information
#
# Table name: collection_items
#
#  id            :bigint           not null, primary key
#  position      :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  collection_id :bigint           not null
#  media_item_id :bigint           not null
#
# Indexes
#
#  index_collection_items_on_collection_id                    (collection_id)
#  index_collection_items_on_collection_id_and_media_item_id  (collection_id,media_item_id) UNIQUE
#  index_collection_items_on_collection_id_and_position       (collection_id,position)
#  index_collection_items_on_media_item_id                    (media_item_id)
#
# Foreign Keys
#
#  fk_rails_...  (collection_id => collections.id)
#  fk_rails_...  (media_item_id => media_items.id)
#
FactoryBot.define do
  factory :collection_item do
    association :collection
    association :media_item
    sequence(:position) { |n| n }
  end
end
