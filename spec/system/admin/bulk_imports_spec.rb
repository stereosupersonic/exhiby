require "capybara_helper"
require "zip"

RSpec.describe "Admin Bulk Imports", type: :system do
  let(:admin) { create(:user, :admin) }
  let(:editor) { create(:user, :editor) }
  let(:user) { create(:user) }

  before do
    visit new_session_path
    fill_in "Email address", with: admin.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  describe "bulk imports listing" do
    it "displays the bulk imports index page" do
      visit admin_bulk_imports_path

      expect(page).to have_selector("[data-testid='admin-bulk-imports']")
      expect(page).to have_selector("[data-testid='bulk-imports-heading']", text: I18n.t("admin.bulk_imports.index.title"))
    end

    it "shows existing imports" do
      bulk_import = create(:bulk_import, created_by: admin)
      visit admin_bulk_imports_path

      expect(page).to have_selector("[data-testid='bulk-import-row-#{bulk_import.id}']")
    end

    it "shows no imports message when empty" do
      visit admin_bulk_imports_path

      expect(page).to have_selector("[data-testid='no-bulk-imports-message']")
    end

    it "shows progress information" do
      create(:bulk_import, :completed, created_by: admin)
      visit admin_bulk_imports_path

      expect(page).to have_content("Abgeschlossen")
    end
  end

  describe "creating a bulk import" do
    let(:zip_path) { create_test_zip_file }

    after { File.delete(zip_path) if File.exist?(zip_path) }

    it "shows the new import form" do
      visit new_admin_bulk_import_path

      expect(page).to have_selector("[data-testid='new-bulk-import-heading']", text: I18n.t("admin.bulk_imports.new.title"))
      expect(page).to have_selector("[data-testid='bulk-import-form']")
    end

    it "displays CSV format help" do
      visit new_admin_bulk_import_path

      expect(page).to have_content("CSV-Format (optional)")
      expect(page).to have_content("filename,title")
    end

    it "allows uploading a ZIP file" do
      visit new_admin_bulk_import_path

      attach_file "ZIP-Datei", zip_path
      click_button "Import starten"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Import wurde gestartet")
      expect(page).to have_selector("[data-testid='admin-bulk-imports-show']")
    end

    it "shows validation error without file" do
      visit new_admin_bulk_import_path
      click_button "Import starten"

      expect(page).to have_current_path(admin_bulk_imports_path)
    end
  end

  describe "viewing a bulk import" do
    let!(:bulk_import) { create(:bulk_import, :completed, created_by: admin) }

    it "displays the import details" do
      visit admin_bulk_import_path(bulk_import)

      expect(page).to have_selector("[data-testid='admin-bulk-imports-show']")
      expect(page).to have_selector("[data-testid='bulk-import-heading']", text: "Import-Details")
    end

    it "shows progress statistics" do
      visit admin_bulk_import_path(bulk_import)

      expect(page).to have_content("Gesamt")
      expect(page).to have_content("Verarbeitet")
      expect(page).to have_content("Erfolgreich")
      expect(page).to have_content("Fehlgeschlagen")
    end

    it "shows import log with tabs" do
      visit admin_bulk_import_path(bulk_import)

      expect(page).to have_content("Import-Protokoll")
      expect(page).to have_selector("#all-tab")
      expect(page).to have_selector("#successful-tab")
      expect(page).to have_selector("#failed-tab")
    end

    it "shows status badge" do
      visit admin_bulk_import_path(bulk_import)

      expect(page).to have_content("Abgeschlossen")
    end
  end

  describe "deleting a bulk import" do
    let!(:bulk_import) { create(:bulk_import, :completed, created_by: admin) }

    it "shows delete button for completed import" do
      visit admin_bulk_imports_path

      expect(page).to have_button("Löschen")
    end

    it "has delete form on show page" do
      visit admin_bulk_import_path(bulk_import)

      expect(page).to have_button("Löschen")
    end
  end

  describe "navigation" do
    it "shows bulk imports link in admin navigation" do
      visit admin_root_path

      expect(page).to have_link(I18n.t("admin.navigation.bulk_imports"), href: admin_bulk_imports_path)
    end
  end

  describe "authorization" do
    context "as regular user" do
      before do
        click_button "Abmelden"
        visit new_session_path
        fill_in "Email address", with: user.email_address
        fill_in "Password", with: "password"
        click_button "Sign In"
      end

      it "allows access to bulk imports" do
        visit admin_bulk_imports_path

        expect(page).to have_selector("[data-testid='admin-bulk-imports']")
      end

      it "only shows own imports" do
        own_import = create(:bulk_import, created_by: user)
        other_import = create(:bulk_import, created_by: admin)

        visit admin_bulk_imports_path

        expect(page).to have_selector("[data-testid='bulk-import-row-#{own_import.id}']")
        expect(page).to have_no_selector("[data-testid='bulk-import-row-#{other_import.id}']")
      end
    end

    context "as editor" do
      before do
        click_button "Abmelden"
        visit new_session_path
        fill_in "Email address", with: editor.email_address
        fill_in "Password", with: "password"
        click_button "Sign In"
      end

      it "shows all imports" do
        create(:bulk_import, created_by: user)
        create(:bulk_import, created_by: admin)

        visit admin_bulk_imports_path

        expect(page).to have_selector("[data-testid='bulk-imports-table']")
        expect(page).to have_selector("tbody tr", count: 2)
      end
    end
  end

  private

  def create_test_zip_file
    temp_dir = Rails.root.join("tmp", "test_zip_#{SecureRandom.hex(4)}")
    FileUtils.mkdir_p(temp_dir)

    zip_path = File.join(temp_dir, "test_import.zip")
    source_image = Rails.root.join("spec/fixtures/files/test_image.png")

    Zip::File.open(zip_path, create: true) do |zipfile|
      zipfile.add("test_image.png", source_image)
    end

    zip_path
  end
end
