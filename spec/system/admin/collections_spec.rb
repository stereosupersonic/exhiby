require "rails_helper"

RSpec.describe "Admin Collections" do
  let(:admin) { create(:user, :admin) }
  let!(:category) { create(:collection_category, name: "Historische Bilder") }

  before do
    visit new_session_path
    fill_in "Email address", with: admin.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  describe "collections listing" do
    it "displays the collections index page" do
      visit admin_collections_path

      expect(page).to have_selector("[data-testid='admin-collections']")
      expect(page).to have_selector("[data-testid='collections-heading']", text: "Sammlungen")
    end

    it "shows existing collections" do
      create(:collection, created_by: admin, name: "Wartenberg Ansichten", collection_category: category)
      visit admin_collections_path

      expect(page).to have_content("Wartenberg Ansichten")
    end

    it "shows no collections message when empty" do
      visit admin_collections_path

      expect(page).to have_selector("[data-testid='no-collections-message']")
    end

    it "allows filtering by status" do
      create(:collection, created_by: admin, name: "Draft Collection", status: "draft", collection_category: category)
      create(:collection, :published, created_by: admin, name: "Published Collection", collection_category: category)

      visit admin_collections_path
      select "Veröffentlicht", from: "status"
      click_button "Filtern"

      expect(page).to have_content("Published Collection")
      expect(page).to have_no_content("Draft Collection")
    end

    it "allows filtering by category" do
      other_category = create(:collection_category, name: "Fotos")
      create(:collection, created_by: admin, name: "Bilder Collection", collection_category: category)
      create(:collection, created_by: admin, name: "Fotos Collection", collection_category: other_category)

      visit admin_collections_path
      select "Historische Bilder", from: "category"
      click_button "Filtern"

      expect(page).to have_content("Bilder Collection")
      expect(page).to have_no_content("Fotos Collection")
    end

    it "allows searching by name" do
      create(:collection, created_by: admin, name: "Alte Ansichtskarten", collection_category: category)
      create(:collection, created_by: admin, name: "Moderne Fotos", collection_category: category)

      visit admin_collections_path
      fill_in "q", with: "Ansichtskarten"
      click_button "Filtern"

      expect(page).to have_content("Alte Ansichtskarten")
      expect(page).to have_no_content("Moderne Fotos")
    end
  end

  describe "creating a collection" do
    it "allows creating a new draft collection" do
      visit admin_collections_path
      click_link "Neue Sammlung", match: :first

      expect(page).to have_selector("[data-testid='collection-form']")

      fill_in "Name", with: "Neue Test Sammlung"
      page.find("[data-testid='collection-category']").select("Historische Bilder")
      click_button "Sammlung erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Sammlung wurde erfolgreich erstellt")
      expect(page).to have_selector("[data-testid='collection-name']", text: "Neue Test Sammlung")
    end

    it "shows validation errors for invalid collection" do
      visit new_admin_collection_path

      click_button "Sammlung erstellen"

      expect(page).to have_content("muss ausgefüllt werden")
    end

    it "auto-generates slug from name" do
      visit new_admin_collection_path

      fill_in "Name", with: "Meine Test Sammlung"
      page.find("[data-testid='collection-category']").select("Historische Bilder")
      click_button "Sammlung erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']")
      expect(Collection.last.slug).to eq("meine-test-sammlung")
    end
  end

  describe "editing a collection" do
    let!(:collection) { create(:collection, created_by: admin, name: "Original Name", collection_category: category) }

    it "allows editing an existing collection" do
      visit admin_collections_path
      click_link "Bearbeiten"

      fill_in "Name", with: "Updated Name"
      click_button "Sammlung speichern"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Sammlung wurde erfolgreich aktualisiert")
      expect(page).to have_selector("[data-testid='collection-name']", text: "Updated Name")
    end
  end

  describe "viewing a collection" do
    let!(:collection) { create(:collection, :published, created_by: admin, name: "Test Sammlung", collection_category: category) }

    it "displays the collection details" do
      visit admin_collection_path(collection)

      expect(page).to have_selector("[data-testid='admin-collection-show']")
      expect(page).to have_selector("[data-testid='collection-name']", text: "Test Sammlung")
    end

    it "displays the category name" do
      visit admin_collection_path(collection)

      expect(page).to have_content("Historische Bilder")
    end
  end

  describe "publishing and unpublishing" do
    let!(:draft_collection) { create(:collection, created_by: admin, name: "Draft Collection", collection_category: category) }
    let!(:published_collection) { create(:collection, :published, created_by: admin, name: "Published Collection", collection_category: category) }

    it "allows publishing a draft collection" do
      visit admin_collection_path(draft_collection)

      click_button "Veröffentlichen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Sammlung wurde veröffentlicht")
      expect(page).to have_selector(".badge.bg-success", text: "Veröffentlicht")
    end

    it "allows unpublishing a published collection" do
      visit admin_collection_path(published_collection)

      click_button "Veröffentlichung zurückziehen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Veröffentlichung wurde zurückgezogen")
      expect(page).to have_selector(".badge.bg-secondary", text: "Entwurf")
    end
  end

  describe "deleting a collection" do
    let!(:collection) { create(:collection, created_by: admin, name: "Collection to Delete", collection_category: category) }

    it "removes collection from the list after deletion" do
      visit admin_collections_path

      expect(page).to have_content("Collection to Delete")

      page.find("[data-testid='delete-collection-#{collection.slug}']").click

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Sammlung wurde erfolgreich gelöscht")
      expect(page).to have_no_content("Collection to Delete")
    end
  end

  describe "navigation" do
    it "shows collections link in admin navigation" do
      visit admin_root_path

      expect(page).to have_link("Sammlungen", href: admin_collections_path)
    end
  end
end
