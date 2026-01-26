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
require "rails_helper"

RSpec.describe CollectionCategory, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:collection_category)).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:collections).dependent(:restrict_with_error) }
  end

  describe "validations" do
    subject { create(:collection_category) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_length_of(:slug).is_at_most(255) }

    describe "slug uniqueness" do
      let!(:existing_category) { create(:collection_category, name: "Existing Category") }

      it "validates uniqueness of slug" do
        new_category = build(:collection_category, name: "Different Name", slug: existing_category.slug)
        new_category.valid?
        expect(new_category.errors[:slug]).to include("ist bereits vergeben")
      end
    end
  end

  describe "scopes" do
    let!(:category_b) { create(:collection_category, name: "Beta", position: 2) }
    let!(:category_a) { create(:collection_category, name: "Alpha", position: 1) }

    describe ".ordered" do
      it "returns categories ordered by position and name" do
        expect(described_class.ordered).to eq([ category_a, category_b ])
      end
    end

    describe ".alphabetical" do
      it "returns categories ordered by name" do
        expect(described_class.alphabetical).to eq([ category_a, category_b ])
      end
    end
  end

  describe "slug generation" do
    it "generates slug from name on create" do
      category = create(:collection_category, name: "Historische Ansichtskarten")
      expect(category.slug).to eq("historische-ansichtskarten")
    end

    it "generates unique slug when names produce same slug" do
      create(:collection_category, name: "Test Category")
      category2 = create(:collection_category, name: "Test-Category")
      expect(category2.slug).to eq("test-category-1")
    end

    it "does not change slug when name is not changed" do
      category = create(:collection_category, name: "Original Name")
      original_slug = category.slug
      category.update!(position: 5)
      expect(category.slug).to eq(original_slug)
    end
  end

  describe "#to_param" do
    it "returns the slug" do
      category = build(:collection_category, slug: "test-slug")
      expect(category.to_param).to eq("test-slug")
    end
  end

  describe "#collections_count" do
    let(:category) { create(:collection_category) }

    it "returns the count of collections" do
      create_list(:collection, 3, collection_category: category)
      expect(category.collections_count).to eq(3)
    end
  end

  describe "#published_collections_count" do
    let(:category) { create(:collection_category) }

    it "returns the count of published collections" do
      create_list(:collection, 2, :published, collection_category: category)
      create(:collection, collection_category: category)
      expect(category.published_collections_count).to eq(2)
    end
  end

  describe "deletion restrictions" do
    let(:category) { create(:collection_category) }

    it "cannot be deleted when collections are assigned" do
      create(:collection, collection_category: category)
      expect(category.destroy).to be false
      expect(category.errors[:base]).not_to be_empty
    end

    it "can be deleted when no collections are assigned" do
      expect(category.destroy).to be_truthy
      expect(described_class.exists?(category.id)).to be false
    end
  end
end
