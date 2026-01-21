require "rails_helper"

RSpec.describe "Public Collections" do
  let!(:category) { create(:collection_category, name: "Historische Ansichtskarten") }

  describe "collections index (Land & Leute)" do
    it "displays the collections page" do
      visit land_und_leute_path

      expect(page).to have_selector("[data-testid='collections-hero']")
      expect(page).to have_selector("[data-testid='collections-heading']", text: "Land & Leute")
    end

    it "shows published collections grouped by category" do
      collection = create(:collection, :published, name: "Wartenberg Ansichten", collection_category: category)

      visit land_und_leute_path

      expect(page).to have_selector("[data-testid='category-section-#{category.slug}']")
      expect(page).to have_content("Historische Ansichtskarten")
      expect(page).to have_selector("[data-testid='collection-card-#{collection.slug}']")
      expect(page).to have_content("Wartenberg Ansichten")
    end

    it "does not show draft collections" do
      create(:collection, name: "Draft Collection", status: "draft", collection_category: category)
      create(:collection, :published, name: "Published Collection", collection_category: category)

      visit land_und_leute_path

      expect(page).to have_content("Published Collection")
      expect(page).to have_no_content("Draft Collection")
    end

    it "shows empty message when no collections exist" do
      visit land_und_leute_path

      expect(page).to have_selector("[data-testid='no-collections-message']")
    end

    it "does not show categories without published collections in main section" do
      empty_category = create(:collection_category, name: "Empty Category")
      create(:collection, :published, name: "Visible Collection", collection_category: category)

      visit land_und_leute_path

      within "[data-testid='collections-section']" do
        expect(page).to have_content("Historische Ansichtskarten")
        expect(page).to have_no_selector("[data-testid='category-section-#{empty_category.slug}']")
      end
    end

    it "shows media items count for collections" do
      collection = create(:collection, :published, :with_media_items, name: "Collection With Items", collection_category: category)

      visit land_und_leute_path

      within "[data-testid='collection-card-#{collection.slug}']" do
        expect(page).to have_content("3 Medien")
      end
    end
  end

  describe "collection show page" do
    let!(:collection) { create(:collection, :published, :with_description, name: "Alte Ansichten", collection_category: category) }

    it "displays the collection details" do
      visit collection_path(collection.slug)

      expect(page).to have_selector("[data-testid='collection-section']")
      expect(page).to have_selector("[data-testid='collection-name']", text: "Alte Ansichten")
    end

    it "displays the collection description" do
      visit collection_path(collection.slug)

      expect(page).to have_selector("[data-testid='collection-description']")
      expect(page).to have_content("Testbeschreibung")
    end

    it "displays the category badge" do
      visit collection_path(collection.slug)

      expect(page).to have_content("Historische Ansichtskarten")
    end

    it "shows back link to Land & Leute" do
      visit collection_path(collection.slug)

      expect(page).to have_link("Zurück", href: land_und_leute_path)
    end

    it "does not display draft collections" do
      draft_collection = create(:collection, name: "Draft", status: "draft", collection_category: category)

      visit collection_path(draft_collection.slug)

      # Draft collections result in a 404 page or redirect
      expect(page).to have_no_selector("[data-testid='collection-name']", text: "Draft")
    end
  end

  describe "navigation" do
    it "is accessible from main navigation" do
      visit root_path

      click_link "Land & Leute"

      expect(page).to have_current_path(land_und_leute_path)
      expect(page).to have_selector("[data-testid='collections-section']")
    end

    it "links from collection card to collection show page" do
      collection = create(:collection, :published, name: "Klickbare Sammlung", collection_category: category)

      visit land_und_leute_path
      click_link "Klickbare Sammlung"

      expect(page).to have_current_path(collection_path(collection.slug))
      expect(page).to have_selector("[data-testid='collection-name']", text: "Klickbare Sammlung")
    end
  end
end
