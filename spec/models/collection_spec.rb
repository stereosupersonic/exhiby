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
require "rails_helper"

RSpec.describe Collection, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:collection)).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:collection_category) }
    it { is_expected.to belong_to(:created_by).class_name("User") }
    it { is_expected.to belong_to(:cover_media_item).class_name("MediaItem").optional }
    it { is_expected.to have_many(:collection_items).dependent(:destroy) }
    it { is_expected.to have_many(:media_items).through(:collection_items) }
    it { is_expected.to have_rich_text(:description) }
  end

  describe "validations" do
    subject { create(:collection) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_length_of(:slug).is_at_most(255) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(Collection::STATUSES) }

    describe "slug uniqueness" do
      let!(:existing_collection) { create(:collection, name: "Existing Collection") }

      it "validates uniqueness of slug" do
        new_collection = build(:collection, name: "Different Name", slug: existing_collection.slug)
        new_collection.valid?
        expect(new_collection.errors[:slug]).to include("ist bereits vergeben")
      end
    end
  end

  describe "scopes" do
    let!(:draft_collection) { create(:collection, status: "draft") }
    let!(:published_collection) { create(:collection, :published) }

    describe ".draft" do
      it "returns only draft collections" do
        expect(described_class.draft).to contain_exactly(draft_collection)
      end
    end

    describe ".published" do
      it "returns only published collections" do
        expect(described_class.published).to contain_exactly(published_collection)
      end
    end

    describe ".ordered" do
      let!(:collection_b) { create(:collection, name: "Beta", position: 2) }
      let!(:collection_a) { create(:collection, name: "Alpha", position: 1) }

      it "returns collections ordered by position and name" do
        result = described_class.where(id: [ collection_a.id, collection_b.id ]).ordered
        expect(result).to eq([ collection_a, collection_b ])
      end
    end

    describe ".search" do
      let!(:matching) { create(:collection, name: "Luftbilder Wartenberg") }
      let!(:non_matching) { create(:collection, name: "Ortsansichten") }

      it "returns collections matching the search query" do
        expect(described_class.search("Luftbilder")).to contain_exactly(matching)
      end

      it "is case insensitive" do
        expect(described_class.search("luftbilder")).to contain_exactly(matching)
      end

      it "returns all when query is blank" do
        expect(described_class.search(nil)).to include(matching, non_matching)
      end
    end
  end

  describe "slug generation" do
    it "generates slug from name on create" do
      collection = create(:collection, name: "Luftbilder Wartenberg")
      expect(collection.slug).to eq("luftbilder-wartenberg")
    end

    it "generates unique slug when duplicate exists" do
      create(:collection, name: "Test Collection")
      collection2 = create(:collection, name: "Test Collection")
      expect(collection2.slug).to eq("test-collection-1")
    end

    it "does not change slug when name is not changed" do
      collection = create(:collection, name: "Original Name")
      original_slug = collection.slug
      collection.update!(position: 5)
      expect(collection.slug).to eq(original_slug)
    end
  end

  describe "#to_param" do
    it "returns the slug" do
      collection = build(:collection, slug: "test-slug")
      expect(collection.to_param).to eq("test-slug")
    end
  end

  describe "#draft?" do
    it "returns true for draft collections" do
      collection = build(:collection, status: "draft")
      expect(collection.draft?).to be true
    end

    it "returns false for published collections" do
      collection = build(:collection, status: "published")
      expect(collection.draft?).to be false
    end
  end

  describe "#published?" do
    it "returns true for published collections" do
      collection = build(:collection, status: "published")
      expect(collection.published?).to be true
    end

    it "returns false for draft collections" do
      collection = build(:collection, status: "draft")
      expect(collection.published?).to be false
    end
  end

  describe "#publish!" do
    let(:collection) { create(:collection, status: "draft") }

    it "changes status to published" do
      collection.publish!
      expect(collection.status).to eq("published")
    end

    it "sets published_at to current time" do
      freeze_time do
        collection.publish!
        expect(collection.published_at).to eq(Time.current)
      end
    end
  end

  describe "#unpublish!" do
    let(:collection) { create(:collection, :published) }

    it "changes status to draft" do
      collection.unpublish!
      expect(collection.status).to eq("draft")
    end

    it "clears published_at" do
      collection.unpublish!
      expect(collection.published_at).to be_nil
    end
  end

  describe "#media_items_count" do
    let(:collection) { create(:collection) }

    it "returns the count of media items" do
      create_list(:collection_item, 3, collection: collection)
      expect(collection.media_items_count).to eq(3)
    end
  end

  describe "constants" do
    it "defines STATUSES" do
      expect(Collection::STATUSES).to eq(%w[draft published])
    end
  end
end
