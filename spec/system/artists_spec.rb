require "capybara_helper"

RSpec.describe "Public Artists", type: :system do
  describe "artists listing" do
    it "displays the artists index page" do
      visit artists_path

      expect(page).to have_selector("[data-testid='artists-hero']")
      expect(page).to have_selector("[data-testid='artists-heading']", text: "Kunstschaffende")
    end

    it "shows only published artists" do
      create(:artist, :published, name: "Published Artist")
      create(:artist, name: "Draft Artist")

      visit artists_path

      expect(page).to have_content("Published Artist")
      expect(page).to have_no_content("Draft Artist")
    end

    it "shows no artists message when empty" do
      visit artists_path

      expect(page).to have_selector("[data-testid='no-artists-message']")
    end

    it "displays artist life dates" do
      create(:artist, :published, :with_dates, name: "Artist with Dates")
      visit artists_path

      expect(page).to have_content("1876 – 1945")
    end
  end

  describe "artist detail page" do
    let!(:artist) { create(:artist, :published, :with_dates, name: "Carl Hans Schrader") }

    it "displays the artist details" do
      visit artist_path(artist.slug)

      expect(page).to have_selector("[data-testid='artist-section']")
      expect(page).to have_selector("[data-testid='artist-name']", text: "Carl Hans Schrader")
    end

    it "shows life info" do
      visit artist_path(artist.slug)

      expect(page).to have_selector("[data-testid='artist-life-info']")
      expect(page).to have_content("geb. 1876 in Hannover")
      expect(page).to have_content("gest. 1945 in Wartenberg")
    end

    it "shows back link" do
      visit artist_path(artist.slug)

      expect(page).to have_link("Zurück zu Kunstschaffende", href: artists_path)
    end

    it "does not show draft artists on the index page" do
      create(:artist, name: "Draft Artist")

      visit artists_path

      expect(page).to have_no_content("Draft Artist")
    end

    context "with media items" do
      let!(:published_media_item) { create(:media_item, :published, artist: artist, title: "Published Artwork") }
      let!(:draft_media_item) { create(:media_item, artist: artist, title: "Draft Artwork") }

      it "shows only published media items" do
        visit artist_path(artist.slug)

        expect(page).to have_content("Published Artwork")
        expect(page).to have_no_content("Draft Artwork")
      end
    end
  end
end
