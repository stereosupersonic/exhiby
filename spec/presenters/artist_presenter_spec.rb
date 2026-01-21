require "rails_helper"

RSpec.describe ArtistPresenter do
  let(:artist) { build(:artist) }
  let(:presenter) { described_class.new(artist) }

  describe "#status_badge_class" do
    it "returns bg-success for published status" do
      artist.status = "published"
      expect(presenter.status_badge_class).to eq("bg-success")
    end

    it "returns bg-secondary for draft status" do
      artist.status = "draft"
      expect(presenter.status_badge_class).to eq("bg-secondary")
    end

    it "returns bg-secondary for unknown status" do
      artist.status = "unknown"
      expect(presenter.status_badge_class).to eq("bg-secondary")
    end
  end

  describe "#status_name" do
    it "returns translated status name" do
      artist.status = "draft"
      expect(presenter.status_name).to eq("Entwurf")
    end
  end

  describe "#formatted_published_at" do
    it "returns formatted date when published_at is present" do
      artist.published_at = Time.zone.local(2024, 3, 15, 10, 30)
      expect(presenter.formatted_published_at).to include("15")
      expect(presenter.formatted_published_at).to include("März")
      expect(presenter.formatted_published_at).to include("2024")
    end

    it "returns not published message when published_at is nil" do
      artist.published_at = nil
      expect(presenter.formatted_published_at).to eq("Nicht veröffentlicht")
    end
  end

  describe "#formatted_birth_date" do
    it "returns formatted date when birth_date is present" do
      artist.birth_date = Date.new(1876, 3, 15)
      expect(presenter.formatted_birth_date).to include("15")
      expect(presenter.formatted_birth_date).to include("März")
      expect(presenter.formatted_birth_date).to include("1876")
    end

    it "returns nil when birth_date is nil" do
      artist.birth_date = nil
      expect(presenter.formatted_birth_date).to be_nil
    end
  end

  describe "#formatted_death_date" do
    it "returns formatted date when death_date is present" do
      artist.death_date = Date.new(1945, 8, 20)
      expect(presenter.formatted_death_date).to include("20")
      expect(presenter.formatted_death_date).to include("August")
      expect(presenter.formatted_death_date).to include("1945")
    end

    it "returns nil when death_date is nil" do
      artist.death_date = nil
      expect(presenter.formatted_death_date).to be_nil
    end
  end

  describe "#creator_email" do
    it "returns the creator email address" do
      user = build(:user, email_address: "creator@example.com")
      artist.created_by = user
      expect(presenter.creator_email).to eq("creator@example.com")
    end
  end

  describe "#display_life_dates" do
    it "delegates to artist#life_dates" do
      artist.birth_date = Date.new(1876, 1, 1)
      artist.death_date = Date.new(1945, 12, 31)
      expect(presenter.display_life_dates).to eq("1876 – 1945")
    end
  end

  describe "#birth_info" do
    it "returns formatted birth info with date and place" do
      artist.birth_date = Date.new(1876, 1, 1)
      artist.birth_place = "Hannover"
      expect(presenter.birth_info).to eq("geb. 1876 in Hannover")
    end

    it "returns formatted birth info with date only" do
      artist.birth_date = Date.new(1876, 1, 1)
      artist.birth_place = nil
      expect(presenter.birth_info).to eq("geb. 1876")
    end

    it "returns formatted birth info with place only" do
      artist.birth_date = nil
      artist.birth_place = "Hannover"
      expect(presenter.birth_info).to eq("in Hannover")
    end

    it "returns nil when no birth info present" do
      artist.birth_date = nil
      artist.birth_place = nil
      expect(presenter.birth_info).to be_nil
    end
  end

  describe "#death_info" do
    it "returns formatted death info with date and place" do
      artist.death_date = Date.new(1945, 12, 31)
      artist.death_place = "Wartenberg"
      expect(presenter.death_info).to eq("gest. 1945 in Wartenberg")
    end

    it "returns formatted death info with date only" do
      artist.death_date = Date.new(1945, 12, 31)
      artist.death_place = nil
      expect(presenter.death_info).to eq("gest. 1945")
    end

    it "returns nil when no death info present" do
      artist.death_date = nil
      artist.death_place = nil
      expect(presenter.death_info).to be_nil
    end
  end

  describe "#full_life_info" do
    it "returns combined birth and death info" do
      artist.birth_date = Date.new(1876, 1, 1)
      artist.birth_place = "Hannover"
      artist.death_date = Date.new(1945, 12, 31)
      artist.death_place = "Wartenberg"
      expect(presenter.full_life_info).to eq("geb. 1876 in Hannover, gest. 1945 in Wartenberg")
    end

    it "returns only birth info when death info is missing" do
      artist.birth_date = Date.new(1876, 1, 1)
      artist.birth_place = "Hannover"
      artist.death_date = nil
      artist.death_place = nil
      expect(presenter.full_life_info).to eq("geb. 1876 in Hannover")
    end

    it "returns empty string when no info present" do
      artist.birth_date = nil
      artist.birth_place = nil
      artist.death_date = nil
      artist.death_place = nil
      expect(presenter.full_life_info).to eq("")
    end
  end

  describe "#media_items_count" do
    let(:artist) { create(:artist) }

    it "returns the count of media items" do
      create_list(:media_item, 3, artist: artist)
      expect(presenter.media_items_count).to eq(3)
    end
  end

  describe "#published_media_items_count" do
    let(:artist) { create(:artist) }

    it "returns the count of published media items" do
      create_list(:media_item, 2, :published, artist: artist)
      create(:media_item, artist: artist)
      expect(presenter.published_media_items_count).to eq(2)
    end
  end
end
