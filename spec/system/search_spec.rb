require "capybara_helper"

RSpec.describe "Search", type: :system do
  describe "search page" do
    it "displays the search page with form" do
      visit search_path

      expect(page).to have_selector("[data-testid='search-hero']")
      expect(page).to have_selector("[data-testid='search-heading']", text: "Suche")
      expect(page).to have_selector("[data-testid='search-form']")
      expect(page).to have_selector("[data-testid='search-input']")
      expect(page).to have_selector("[data-testid='search-submit']")
    end

    it "shows prompt message when no query is entered" do
      visit search_path

      expect(page).to have_selector("[data-testid='no-query-message']")
      expect(page).to have_content("Bitte geben Sie einen Suchbegriff ein")
    end
  end

  describe "header search box" do
    it "has search box in header" do
      visit root_path

      expect(page).to have_selector("[data-testid='header-search']")
      expect(page).to have_selector("[data-testid='header-search-input']")
      expect(page).to have_selector("[data-testid='header-search-submit']")
    end

    it "searching from header navigates to search results" do
      create(:article, :published, title: "Testbeitrag Suche")

      visit root_path

      fill_in "q", with: "Testbeitrag"
      find("[data-testid='header-search-submit']").click

      expect(page).to have_selector("[data-testid='search-section']")
      expect(page).to have_content("Testbeitrag Suche")
    end
  end

  describe "searching media items" do
    it "finds media items by title" do
      create(:media_item, :published, title: "Historisches Foto Wartenberg")
      create(:media_item, :published, title: "Unrelated Media")

      visit search_path(q: "Wartenberg")

      expect(page).to have_selector("[data-testid='results-heading']")
      expect(page).to have_selector("[data-testid='media-items-results']")
      expect(page).to have_content("Historisches Foto Wartenberg")
      expect(page).to have_no_content("Unrelated Media")
    end

    it "finds media items by tag name" do
      tag = create(:media_tag, name: "Postkarte")
      media_item = create(:media_item, :published, title: "Altes Bild")
      media_item.media_tags << tag

      visit search_path(q: "Postkarte")

      expect(page).to have_selector("[data-testid='media-items-results']")
      expect(page).to have_content("Altes Bild")
    end

    it "does not find draft media items" do
      create(:media_item, title: "Draft Media", status: "draft")

      visit search_path(q: "Draft")

      expect(page).to have_no_content("Draft Media")
    end
  end

  describe "searching articles" do
    it "finds articles by title" do
      create(:article, :published, title: "Museum Geschichte")
      create(:article, :published, title: "Andere Themen")

      visit search_path(q: "Museum")

      expect(page).to have_selector("[data-testid='articles-results']")
      expect(page).to have_content("Museum Geschichte")
      expect(page).to have_no_content("Andere Themen")
    end

    it "finds articles by content" do
      create(:article, :published, title: "Testbeitrag", content: "Ein Text über das Rathaus in Wartenberg")

      visit search_path(q: "Rathaus")

      expect(page).to have_selector("[data-testid='articles-results']")
      expect(page).to have_content("Testbeitrag")
    end

    it "does not find draft articles" do
      create(:article, title: "Draft Article", status: "draft")

      visit search_path(q: "Draft")

      expect(page).to have_no_content("Draft Article")
    end
  end

  describe "searching collections" do
    it "finds collections by name" do
      create(:collection, :published, name: "Historische Ansichtskarten")
      create(:collection, :published, name: "Andere Sammlung")

      visit search_path(q: "Ansichtskarten")

      expect(page).to have_selector("[data-testid='collections-results']")
      expect(page).to have_content("Historische Ansichtskarten")
      expect(page).to have_no_content("Andere Sammlung")
    end

    it "finds collections by description" do
      create(:collection, :published, name: "Testsammlung", description: "Eine Sammlung mit alten Fotografien")

      visit search_path(q: "Fotografien")

      expect(page).to have_selector("[data-testid='collections-results']")
      expect(page).to have_content("Testsammlung")
    end

    it "does not find draft collections" do
      create(:collection, name: "Draft Sammlung", status: "draft")

      visit search_path(q: "Draft")

      expect(page).to have_no_content("Draft Sammlung")
    end
  end

  describe "searching artists" do
    it "finds artists by name" do
      create(:artist, :published, name: "Max Mustermann")
      create(:artist, :published, name: "Andere Person")

      visit search_path(q: "Mustermann")

      expect(page).to have_selector("[data-testid='artists-results']")
      within("[data-testid='artists-results']") do
        expect(page).to have_content("Max Mustermann")
        expect(page).to have_no_content("Andere Person")
      end
    end

    it "finds artists by biography" do
      create(:artist, :published, name: "Testkuenstler", biography: "Geboren in Wartenberg, bekannt fuer seine Landschaftsbilder")

      visit search_path(q: "Landschaftsbilder")

      expect(page).to have_selector("[data-testid='artists-results']")
      expect(page).to have_content("Testkuenstler")
    end

    it "does not find draft artists" do
      create(:artist, name: "Draft Kuenstler", status: "draft")

      visit search_path(q: "Draft")

      expect(page).to have_no_content("Draft Kuenstler")
    end
  end

  describe "no results" do
    it "shows no results message when nothing matches" do
      visit search_path(q: "xyz123nonexistent")

      expect(page).to have_selector("[data-testid='no-results-message']")
      expect(page).to have_content("Keine Ergebnisse gefunden")
    end
  end

  describe "combined search results" do
    it "displays results from all types" do
      create(:media_item, :published, title: "Wartenberg Bild")
      create(:article, :published, title: "Wartenberg Geschichte")
      create(:collection, :published, name: "Wartenberg Sammlung")
      create(:artist, :published, name: "Wartenberg Kuenstler")

      visit search_path(q: "Wartenberg")

      expect(page).to have_selector("[data-testid='media-items-results']")
      expect(page).to have_selector("[data-testid='artists-results']")
      expect(page).to have_selector("[data-testid='articles-results']")
      expect(page).to have_selector("[data-testid='collections-results']")
    end
  end

  describe "search form submission" do
    it "allows searching via form submission" do
      create(:article, :published, title: "Suchartikel Test")

      visit search_path

      within("[data-testid='search-form']") do
        fill_in "q", with: "Suchartikel"
        click_button "Suchen"
      end

      expect(page).to have_content("Suchartikel Test")
    end
  end
end
