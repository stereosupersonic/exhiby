# == Schema Information
#
# Table name: artists
#
#  id                    :bigint           not null, primary key
#  birth_date            :date
#  birth_place           :string
#  death_date            :date
#  death_place           :string
#  name                  :string           not null
#  published_at          :datetime
#  slug                  :string           not null
#  status                :string           default("draft"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  created_by_id         :bigint           not null
#  profile_media_item_id :bigint
#
# Indexes
#
#  index_artists_on_created_by_id          (created_by_id)
#  index_artists_on_profile_media_item_id  (profile_media_item_id)
#  index_artists_on_published_at           (published_at)
#  index_artists_on_slug                   (slug) UNIQUE
#  index_artists_on_status                 (status)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (profile_media_item_id => media_items.id)
#
require "rails_helper"

RSpec.describe Artist, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:created_by).class_name("User") }
    it { is_expected.to belong_to(:profile_media_item).class_name("MediaItem").optional }
    it { is_expected.to have_many(:media_items).dependent(:restrict_with_error) }
    it { is_expected.to have_one_attached(:profile_image) }
    it { is_expected.to have_rich_text(:biography) }
    it { is_expected.to have_rich_text(:cv) }
  end

  describe "validations" do
    subject { build(:artist) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_length_of(:slug).is_at_most(255) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(Artist::STATUSES) }

    describe "slug uniqueness" do
      let!(:existing_artist) { create(:artist, name: "Unique Artist") }

      it "validates uniqueness of slug" do
        new_artist = build(:artist, slug: existing_artist.slug)
        new_artist.valid?
        expect(new_artist.errors[:slug]).to include("ist bereits vergeben")
      end
    end
  end

  describe "scopes" do
    let!(:draft_artist) { create(:artist, status: "draft") }
    let!(:published_artist) { create(:artist, :published) }

    describe ".draft" do
      it "returns only draft artists" do
        expect(Artist.draft).to contain_exactly(draft_artist)
      end
    end

    describe ".published" do
      it "returns only published artists" do
        expect(Artist.published).to contain_exactly(published_artist)
      end
    end

    describe ".alphabetical" do
      let!(:artist_b) { create(:artist, name: "Bernd Artist") }
      let!(:artist_a) { create(:artist, name: "Anna Artist") }

      it "returns artists ordered by name" do
        expect(Artist.alphabetical.first(2)).to eq([ artist_a, artist_b ])
      end
    end

    describe ".search" do
      let!(:matching_artist) { create(:artist, name: "Hans Maler") }
      let!(:non_matching_artist) { create(:artist, name: "Peter Bildhauer") }

      it "returns artists matching the search query" do
        expect(Artist.search("Maler")).to contain_exactly(matching_artist)
      end

      it "is case insensitive" do
        expect(Artist.search("maler")).to contain_exactly(matching_artist)
      end

      it "returns all when query is blank" do
        expect(Artist.search(nil)).to include(matching_artist, non_matching_artist)
      end
    end
  end

  describe "slug generation" do
    it "generates slug from name on create" do
      artist = create(:artist, name: "Carl Hans Schrader")
      expect(artist.slug).to eq("carl-hans-schrader")
    end

    it "generates unique slug when duplicate exists" do
      create(:artist, name: "Test Artist")
      artist2 = create(:artist, name: "Test Artist")
      expect(artist2.slug).to eq("test-artist-1")
    end

    it "does not change slug when name is not changed" do
      artist = create(:artist, name: "Original Name")
      original_slug = artist.slug
      artist.update!(birth_place: "Berlin")
      expect(artist.slug).to eq(original_slug)
    end
  end

  describe "#to_param" do
    it "returns the slug" do
      artist = build(:artist, slug: "test-slug")
      expect(artist.to_param).to eq("test-slug")
    end
  end

  describe "#draft?" do
    it "returns true for draft artists" do
      artist = build(:artist, status: "draft")
      expect(artist.draft?).to be true
    end

    it "returns false for published artists" do
      artist = build(:artist, status: "published")
      expect(artist.draft?).to be false
    end
  end

  describe "#published?" do
    it "returns true for published artists" do
      artist = build(:artist, status: "published")
      expect(artist.published?).to be true
    end

    it "returns false for draft artists" do
      artist = build(:artist, status: "draft")
      expect(artist.published?).to be false
    end
  end

  describe "#publish!" do
    let(:artist) { create(:artist, status: "draft") }

    it "changes status to published" do
      artist.publish!
      expect(artist.status).to eq("published")
    end

    it "sets published_at to current time" do
      freeze_time do
        artist.publish!
        expect(artist.published_at).to eq(Time.current)
      end
    end
  end

  describe "#unpublish!" do
    let(:artist) { create(:artist, :published) }

    it "changes status to draft" do
      artist.unpublish!
      expect(artist.status).to eq("draft")
    end

    it "clears published_at" do
      artist.unpublish!
      expect(artist.published_at).to be_nil
    end
  end

  describe "deletion restrictions" do
    let(:artist) { create(:artist) }

    it "cannot be deleted when media items are assigned" do
      create(:media_item, artist: artist)
      expect(artist.destroy).to be false
      expect(artist.errors[:base]).not_to be_empty
    end

    it "can be deleted when no media items are assigned" do
      expect(artist.destroy).to be_truthy
      expect(Artist.exists?(artist.id)).to be false
    end
  end

  describe "#life_dates" do
    it "returns formatted date range when both dates present" do
      artist = build(:artist, birth_date: Date.new(1876, 1, 1), death_date: Date.new(1945, 12, 31))
      expect(artist.life_dates).to eq("1876 – 1945")
    end

    it "returns birth year only format when only birth date present" do
      artist = build(:artist, birth_date: Date.new(1876, 1, 1), death_date: nil)
      expect(artist.life_dates).to eq("geb. 1876")
    end

    it "returns death year only format when only death date present" do
      artist = build(:artist, birth_date: nil, death_date: Date.new(1945, 12, 31))
      expect(artist.life_dates).to eq("gest. 1945")
    end

    it "returns nil when no dates present" do
      artist = build(:artist, birth_date: nil, death_date: nil)
      expect(artist.life_dates).to be_nil
    end
  end
end
