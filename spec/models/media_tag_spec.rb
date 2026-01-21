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
require "rails_helper"

RSpec.describe MediaTag do
  describe "associations" do
    it { is_expected.to have_many(:media_taggings).dependent(:destroy) }
    it { is_expected.to have_many(:media_items).through(:media_taggings) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }

    describe "uniqueness" do
      let!(:existing_tag) { create(:media_tag, name: "Existing Tag") }

      it "validates uniqueness of name case-insensitively" do
        tag = build(:media_tag, name: "existing tag")
        expect(tag).not_to be_valid
        expect(tag.errors[:name]).to be_present
      end
    end
  end

  describe "slug generation" do
    it "generates slug from name on create" do
      tag = create(:media_tag, name: "Local History")
      expect(tag.slug).to eq("local-history")
    end

    it "updates slug when name changes" do
      tag = create(:media_tag, name: "Original Name")
      tag.update!(name: "New Name")
      expect(tag.slug).to eq("new-name")
    end
  end

  describe "scopes" do
    describe ".popular" do
      let!(:popular_tag) { create(:media_tag, media_items_count: 10) }
      let!(:unpopular_tag) { create(:media_tag, media_items_count: 2) }

      it "orders by media_items_count desc" do
        expect(described_class.popular.first).to eq(popular_tag)
      end
    end

    describe ".alphabetical" do
      let!(:tag_b) { create(:media_tag, name: "Beta") }
      let!(:tag_a) { create(:media_tag, name: "Alpha") }

      it "orders by name" do
        expect(described_class.alphabetical).to eq([ tag_a, tag_b ])
      end
    end
  end

  describe ".find_or_create_by_name" do
    it "finds existing tag case-insensitively" do
      existing = create(:media_tag, name: "History")
      found = described_class.find_or_create_by_name("history")
      expect(found).to eq(existing)
    end

    it "creates new tag if not found" do
      expect { described_class.find_or_create_by_name("New Tag") }
        .to change(described_class, :count).by(1)
    end
  end
end
