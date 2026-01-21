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
require "rails_helper"

RSpec.describe CollectionItem, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:collection) }
    it { is_expected.to belong_to(:media_item) }
  end

  describe "validations" do
    subject { build(:collection_item) }

    it { is_expected.to validate_uniqueness_of(:media_item_id).scoped_to(:collection_id) }
  end

  describe "scopes" do
    describe ".ordered" do
      let(:collection) { create(:collection) }
      let!(:item_2) { create(:collection_item, collection: collection, position: 2) }
      let!(:item_1) { create(:collection_item, collection: collection, position: 1) }
      let!(:item_3) { create(:collection_item, collection: collection, position: 3) }

      it "returns items ordered by position" do
        expect(described_class.ordered).to eq([ item_1, item_2, item_3 ])
      end
    end
  end

  describe ".reorder" do
    let(:collection) { create(:collection) }
    let(:media_item_1) { create(:media_item) }
    let(:media_item_2) { create(:media_item) }
    let(:media_item_3) { create(:media_item) }

    before do
      create(:collection_item, collection: collection, media_item: media_item_1, position: 0)
      create(:collection_item, collection: collection, media_item: media_item_2, position: 1)
      create(:collection_item, collection: collection, media_item: media_item_3, position: 2)
    end

    it "updates positions based on array order" do
      described_class.reorder(collection, [ media_item_3.id, media_item_1.id, media_item_2.id ])

      expect(described_class.find_by(collection: collection, media_item: media_item_3).position).to eq(0)
      expect(described_class.find_by(collection: collection, media_item: media_item_1).position).to eq(1)
      expect(described_class.find_by(collection: collection, media_item: media_item_2).position).to eq(2)
    end
  end
end
