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
require "rails_helper"

RSpec.describe Technique, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:technique)).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:media_items).dependent(:nullify) }
  end

  describe "validations" do
    subject { create(:technique) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_length_of(:slug).is_at_most(255) }

    describe "slug uniqueness" do
      let!(:existing_technique) { create(:technique, name: "Existing Technique") }

      it "validates uniqueness of slug" do
        new_technique = build(:technique, name: "Different Name", slug: existing_technique.slug)
        expect(new_technique).not_to be_valid
        expect(new_technique.errors[:slug]).to be_present
      end
    end
  end

  describe "scopes" do
    let!(:technique_b) { create(:technique, name: "Aquarell", position: 2) }
    let!(:technique_a) { create(:technique, name: "Ölmalerei", position: 1) }
    let!(:technique_c) { create(:technique, name: "Fotografie", position: 1) }

    describe ".ordered" do
      it "returns techniques ordered by position and name" do
        expect(described_class.ordered).to eq([ technique_c, technique_a, technique_b ])
      end
    end

    describe ".search" do
      it "returns techniques matching the query" do
        expect(described_class.search("Aqua")).to eq([ technique_b ])
      end

      it "is case insensitive" do
        expect(described_class.search("aquarell")).to eq([ technique_b ])
      end

      it "returns all techniques when query is blank" do
        expect(described_class.search("")).to match_array([ technique_a, technique_b, technique_c ])
      end

      it "returns all techniques when query is nil" do
        expect(described_class.search(nil)).to match_array([ technique_a, technique_b, technique_c ])
      end

      it "returns empty array when no match found" do
        expect(described_class.search("Skulptur")).to be_empty
      end
    end
  end

  describe "slug generation" do
    it "generates slug from name on create" do
      technique = create(:technique, name: "Öl auf Leinwand")
      expect(technique.slug).to eq("ol-auf-leinwand")
    end

    it "generates unique slug when names produce same slug" do
      create(:technique, name: "Test Technique")
      technique2 = create(:technique, name: "Test-Technique")
      expect(technique2.slug).to eq("test-technique-1")
    end

    it "preserves manually set slug on create" do
      technique = create(:technique, name: "Aquarell", slug: "custom-slug")
      expect(technique.slug).to eq("custom-slug")
    end

    it "does not change slug when name is not changed" do
      technique = create(:technique, name: "Original Name")
      original_slug = technique.slug
      technique.update!(position: 5)
      expect(technique.slug).to eq(original_slug)
    end

    it "updates slug when name is changed" do
      technique = create(:technique, name: "Original Name")
      technique.update!(name: "New Name")
      expect(technique.slug).to eq("new-name")
    end

    it "handles duplicate slugs on name update" do
      create(:technique, name: "Existing Technique")
      technique = create(:technique, name: "Other Technique")
      technique.update!(name: "Existing Technique Copy")
      expect(technique.name).to eq("Existing Technique Copy")
    end
  end

  describe "#to_param" do
    it "returns the slug" do
      technique = build(:technique, slug: "test-slug")
      expect(technique.to_param).to eq("test-slug")
    end
  end

  describe "dependent nullify behavior" do
    let(:technique) { create(:technique) }

    it "nullifies media_item technique reference when deleted" do
      media_item = create(:media_item, technique: technique)
      technique.destroy
      expect(media_item.reload.technique_id).to be_nil
    end

    it "can be deleted when media items are assigned" do
      create(:media_item, technique: technique)
      expect(technique.destroy).to be_truthy
      expect(described_class.exists?(technique.id)).to be false
    end
  end
end
