require "rails_helper"

RSpec.describe "Admin Collection Categories", type: :system do
  let(:admin) { create(:user, :admin) }

  before do
    visit new_session_path
    fill_in "Email address", with: admin.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  describe "collection categories listing" do
    it "displays the collection categories index page" do
      visit admin_collection_categories_path

      expect(page).to have_selector("[data-testid='admin-collection-categories']")
      expect(page).to have_selector("[data-testid='collection-categories-heading']", text: "Sammlungskategorien")
    end

    it "shows existing collection categories" do
      create(:collection_category, name: "Historische Ansichtskarten")
      visit admin_collection_categories_path

      expect(page).to have_content("Historische Ansichtskarten")
    end

    it "shows no categories message when empty" do
      visit admin_collection_categories_path

      expect(page).to have_selector("[data-testid='no-collection-categories-message']")
    end

    it "displays categories in order by position" do
      create(:collection_category, name: "Second Category", position: 2)
      create(:collection_category, name: "First Category", position: 1)

      visit admin_collection_categories_path

      rows = page.all("[data-testid^='collection-category-row-']")
      expect(rows[0]).to have_content("First Category")
      expect(rows[1]).to have_content("Second Category")
    end

    it "shows the collections count for each category" do
      category = create(:collection_category, name: "Test Category")
      create_list(:collection, 3, collection_category: category)

      visit admin_collection_categories_path

      expect(page).to have_selector("[data-testid='collection-category-row-#{category.slug}']", text: "3")
    end
  end

  describe "creating a collection category" do
    it "allows creating a new collection category" do
      visit admin_collection_categories_path
      click_link "Neue Kategorie", match: :first

      expect(page).to have_selector("[data-testid='admin-collection-categories-new']")

      fill_in "Name", with: "Historische Fotos"
      click_button "Kategorie erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Kategorie wurde erfolgreich erstellt")
      expect(page).to have_content("Historische Fotos")
    end

    it "allows setting position when creating" do
      visit new_admin_collection_category_path

      fill_in "Name", with: "Test Category"
      fill_in "Position", with: "5"
      click_button "Kategorie erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Kategorie wurde erfolgreich erstellt")

      category = CollectionCategory.last
      expect(category.position).to eq(5)
    end

    it "shows validation errors for invalid category" do
      visit new_admin_collection_category_path

      click_button "Kategorie erstellen"

      expect(page).to have_content("muss ausgefüllt werden")
    end

    it "shows validation error for duplicate name" do
      create(:collection_category, name: "Existing Category")

      visit new_admin_collection_category_path
      fill_in "Name", with: "Existing Category"
      click_button "Kategorie erstellen"

      expect(page).to have_content("ist bereits vergeben")
    end
  end

  describe "editing a collection category" do
    let!(:category) { create(:collection_category, name: "Original Name", position: 1) }

    it "allows editing an existing category" do
      visit admin_collection_categories_path
      click_link "Bearbeiten"

      expect(page).to have_selector("[data-testid='admin-collection-categories-edit']")

      fill_in "Name", with: "Updated Name"
      click_button "Kategorie speichern"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Kategorie wurde erfolgreich aktualisiert")
      expect(page).to have_content("Updated Name")
    end

    it "allows updating the position" do
      visit edit_admin_collection_category_path(category)

      fill_in "Position", with: "10"
      click_button "Kategorie speichern"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Kategorie wurde erfolgreich aktualisiert")
      expect(category.reload.position).to eq(10)
    end
  end

  describe "deleting a collection category" do
    context "when category has no collections" do
      let!(:category) { create(:collection_category, name: "Category to Delete") }

      it "removes category from the list after deletion" do
        visit admin_collection_categories_path

        expect(page).to have_content("Category to Delete")

        page.find("[data-testid='delete-collection-category-#{category.slug}']").click

        expect(page).to have_selector("[data-testid='flash-notice']", text: "Kategorie wurde erfolgreich gelöscht")
        expect(page).to have_no_content("Category to Delete")
      end
    end

    context "when category has collections" do
      let!(:category) { create(:collection_category, name: "Category with Collections") }

      before do
        create(:collection, collection_category: category)
      end

      it "shows error message and does not delete the category" do
        visit admin_collection_categories_path

        page.find("[data-testid='delete-collection-category-#{category.slug}']").click

        expect(page).to have_selector("[data-testid='flash-alert']", text: "Kategorie kann nicht gelöscht werden")
        expect(page).to have_content("Category with Collections")
      end
    end
  end

  describe "navigation" do
    it "shows collection categories link in admin navigation" do
      visit admin_root_path

      expect(page).to have_link("Kategorien", href: admin_collection_categories_path)
    end
  end
end
