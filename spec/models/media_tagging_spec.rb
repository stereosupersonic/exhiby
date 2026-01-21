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
require "rails_helper"

RSpec.describe MediaTagging do
  describe "associations" do
    it { is_expected.to belong_to(:media_item) }
    it { is_expected.to belong_to(:media_tag).counter_cache(:media_items_count) }
  end

  describe "validations" do
    subject { create(:media_tagging) }

    it { is_expected.to validate_uniqueness_of(:media_item_id).scoped_to(:media_tag_id) }
  end

  describe "counter cache" do
    let(:media_tag) { create(:media_tag) }
    let(:media_item) { create(:media_item) }

    it "increments media_items_count when tagging is created" do
      expect { create(:media_tagging, media_item: media_item, media_tag: media_tag) }
        .to change { media_tag.reload.media_items_count }.by(1)
    end

    it "decrements media_items_count when tagging is destroyed" do
      tagging = create(:media_tagging, media_item: media_item, media_tag: media_tag)
      expect { tagging.destroy }
        .to change { media_tag.reload.media_items_count }.by(-1)
    end
  end
end
