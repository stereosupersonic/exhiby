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
# Indexes
#
#  index_media_taggings_on_media_item_id                   (media_item_id)
#  index_media_taggings_on_media_item_id_and_media_tag_id  (media_item_id,media_tag_id) UNIQUE
#  index_media_taggings_on_media_tag_id                    (media_tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (media_item_id => media_items.id)
#  fk_rails_...  (media_tag_id => media_tags.id)
#
class MediaTagging < ApplicationRecord
  belongs_to :media_item
  belongs_to :media_tag, counter_cache: :media_items_count

  validates :media_item_id, uniqueness: { scope: :media_tag_id }
end
