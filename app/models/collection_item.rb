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
class CollectionItem < ApplicationRecord
  belongs_to :collection
  belongs_to :media_item

  validates :media_item_id, uniqueness: { scope: :collection_id }

  scope :ordered, -> { order(:position) }

  def self.reorder(collection, media_item_ids)
    transaction do
      media_item_ids.each_with_index do |media_item_id, index|
        where(collection: collection, media_item_id: media_item_id)
          .update_all(position: index)
      end
    end
  end
end
