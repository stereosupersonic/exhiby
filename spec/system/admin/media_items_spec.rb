require "capybara_helper"

RSpec.describe "Admin Media Items", type: :system do
  let(:admin) { create(:user, :admin) }
  let(:editor) { create(:user, :editor) }

  before do
    visit new_session_path
    fill_in "Email address", with: admin.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  describe "media items listing" do
    it "displays the media items index page" do
      visit admin_media_items_path

      expect(page).to have_selector("[data-testid='admin-media-items']")
      expect(page).to have_selector("[data-testid='media-items-heading']", text: "Medien")
    end

    it "shows existing media items" do
      create(:media_item, uploaded_by: admin, title: "Test Media Item")
      visit admin_media_items_path

      expect(page).to have_content("Test Media Item")
    end

    it "shows no media items message when empty" do
      visit admin_media_items_path

      expect(page).to have_selector("[data-testid='no-media-items-message']")
    end

    it "filters by status" do
      create(:media_item, uploaded_by: admin, title: "Draft Item", status: "draft")
      create(:media_item, :published, uploaded_by: admin, title: "Published Item")
      visit admin_media_items_path

      select "Veröffentlicht", from: "status"
      click_button "Filtern"

      expect(page).to have_content("Published Item")
      expect(page).to have_no_content("Draft Item")
    end

    it "filters by media type" do
      create(:media_item, uploaded_by: admin, title: "Image Item", media_type: "image")
      create(:media_item, :video, uploaded_by: admin, title: "Video Item")
      visit admin_media_items_path

      select "Video", from: "media_type"
      click_button "Filtern"

      expect(page).to have_content("Video Item")
      expect(page).to have_no_content("Image Item")
    end
  end

  describe "creating a media item" do
    it "allows creating a new media item" do
      visit admin_media_items_path
      click_link "Neues Medium", match: :first

      expect(page).to have_selector("[data-testid='admin-media-item-new']")

      fill_in "Titel", with: "My New Media Item"
      select "Bild", from: "Medientyp"
      attach_file "Datei", Rails.root.join("spec/fixtures/files/test_image.png")
      click_button "Medium erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Medium wurde erfolgreich erstellt")
      expect(page).to have_selector("[data-testid='media-item-title']", text: "My New Media Item")
    end

    it "shows validation errors for invalid media item" do
      visit new_admin_media_item_path

      click_button "Medium erstellen"

      expect(page).to have_content("muss ausgefüllt werden")
    end
  end

  describe "editing a media item" do
    let!(:media_item) { create(:media_item, uploaded_by: admin, title: "Original Title") }

    it "allows editing an existing media item" do
      visit admin_media_item_path(media_item)
      click_link "Bearbeiten"

      expect(page).to have_selector("[data-testid='admin-media-item-edit']")

      fill_in "Titel", with: "Updated Title"
      click_button "Medium speichern"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Medium wurde erfolgreich aktualisiert")
      expect(page).to have_selector("[data-testid='media-item-title']", text: "Updated Title")
    end
  end

  describe "viewing a media item" do
    let!(:media_item) { create(:media_item, :published, uploaded_by: admin, title: "Test Media Item") }

    it "displays the media item details" do
      visit admin_media_item_path(media_item)

      expect(page).to have_selector("[data-testid='admin-media-item-show']")
      expect(page).to have_selector("[data-testid='media-item-title']", text: "Test Media Item")
    end
  end

  describe "workflow actions" do
    describe "submitting for review" do
      let!(:media_item) { create(:media_item, uploaded_by: admin, status: "draft") }

      it "allows submitting a draft for review" do
        visit admin_media_item_path(media_item)

        click_button "Zur Prüfung einreichen"

        expect(page).to have_selector("[data-testid='flash-notice']", text: "Medium wurde zur Prüfung eingereicht")
        expect(page).to have_content("In Prüfung")
      end
    end

    describe "publishing" do
      let!(:media_item) { create(:media_item, :pending_review, uploaded_by: admin) }

      it "allows publishing a pending media item" do
        visit admin_media_item_path(media_item)

        click_button "Veröffentlichen"

        expect(page).to have_selector("[data-testid='flash-notice']", text: "Medium wurde veröffentlicht")
        expect(page).to have_content("Veröffentlicht")
      end
    end

    describe "rejecting" do
      let!(:media_item) { create(:media_item, :pending_review, uploaded_by: admin) }

      it "allows rejecting a pending media item" do
        visit admin_media_item_path(media_item)

        click_button "Ablehnen"

        expect(page).to have_selector("[data-testid='flash-notice']", text: "Medium wurde abgelehnt")
        expect(page).to have_content("Entwurf")
      end
    end

    describe "unpublishing" do
      let!(:media_item) { create(:media_item, :published, uploaded_by: admin) }

      it "allows unpublishing a published media item" do
        visit admin_media_item_path(media_item)

        click_button "Veröffentlichung zurückziehen"

        expect(page).to have_selector("[data-testid='flash-notice']", text: "Veröffentlichung wurde zurückgezogen")
        expect(page).to have_content("Entwurf")
      end
    end
  end

  describe "navigation" do
    it "shows media items link in admin navigation" do
      visit admin_root_path

      expect(page).to have_link("Medien", href: admin_media_items_path)
    end
  end
end
