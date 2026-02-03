require "capybara_helper"

RSpec.describe "Admin Media Tags", type: :system do
  let(:admin) { create(:user, :admin) }

  before do
    visit new_session_path
    fill_in "Email address", with: admin.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  describe "media tags listing" do
    it "displays the media tags index page" do
      visit admin_media_tags_path

      expect(page).to have_selector("[data-testid='admin-media-tags']")
      expect(page).to have_selector("[data-testid='media-tags-heading']", text: "Tags")
    end

    it "shows existing media tags" do
      create(:media_tag, name: "Geschichte")
      visit admin_media_tags_path

      expect(page).to have_content("Geschichte")
    end

    it "shows no tags message when empty" do
      visit admin_media_tags_path

      expect(page).to have_selector("[data-testid='no-media-tags-message']")
    end

    it "displays tags in alphabetical order" do
      create(:media_tag, name: "Zebra")
      create(:media_tag, name: "Alpha")

      visit admin_media_tags_path

      rows = page.all("[data-testid^='media-tag-row-']")
      expect(rows[0]).to have_content("Alpha")
      expect(rows[1]).to have_content("Zebra")
    end

    it "shows the media items count for each tag" do
      tag = create(:media_tag, name: "Test Tag")
      media_item = create(:media_item)
      create(:media_tagging, media_tag: tag, media_item: media_item)

      visit admin_media_tags_path

      expect(page).to have_selector("[data-testid='media-tag-row-#{tag.id}']", text: "1")
    end

    it "shows the slug for each tag" do
      create(:media_tag, name: "Local History")
      visit admin_media_tags_path

      expect(page).to have_content("local-history")
    end
  end

  describe "creating a media tag" do
    it "allows creating a new media tag" do
      visit admin_media_tags_path
      click_link "Neuer Tag", match: :first

      expect(page).to have_selector("[data-testid='admin-media-tag-new']")

      fill_in "Name", with: "Kunst"
      click_button "Tag erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Tag wurde erfolgreich erstellt")
      expect(page).to have_content("Kunst")
    end

    it "automatically generates slug from name" do
      visit new_admin_media_tag_path

      fill_in "Name", with: "Lokale Geschichte"
      click_button "Tag erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']")
      expect(MediaTag.last.slug).to eq("lokale-geschichte")
    end

    it "shows validation errors for invalid tag" do
      visit new_admin_media_tag_path

      click_button "Tag erstellen"

      expect(page).to have_content("muss ausgefüllt werden")
    end

    it "shows validation error for duplicate name" do
      create(:media_tag, name: "Existing Tag")

      visit new_admin_media_tag_path
      fill_in "Name", with: "existing tag"
      click_button "Tag erstellen"

      expect(page).to have_content("ist bereits vergeben")
    end
  end

  describe "editing a media tag" do
    let!(:tag) { create(:media_tag, name: "Original Name") }

    it "allows editing an existing tag" do
      visit admin_media_tags_path
      click_link "Bearbeiten"

      expect(page).to have_selector("[data-testid='admin-media-tag-edit']")

      fill_in "Name", with: "Updated Name"
      click_button "Tag speichern"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Tag wurde erfolgreich aktualisiert")
      expect(page).to have_content("Updated Name")
    end

    it "updates the slug when name changes" do
      visit edit_admin_media_tag_path(tag)

      fill_in "Name", with: "New Tag Name"
      click_button "Tag speichern"

      expect(tag.reload.slug).to eq("new-tag-name")
    end
  end

  describe "viewing a media tag" do
    let!(:tag) { create(:media_tag, name: "Test Tag") }

    it "displays the tag details" do
      visit admin_media_tag_path(tag)

      expect(page).to have_selector("[data-testid='admin-media-tag-show']")
      expect(page).to have_selector("[data-testid='media-tag-name']", text: "Test Tag")
    end

    it "shows associated media items" do
      media_item = create(:media_item, title: "Tagged Media Item")
      create(:media_tagging, media_tag: tag, media_item: media_item)

      visit admin_media_tag_path(tag)

      expect(page).to have_content("Tagged Media Item")
    end

    it "shows empty message when no media items" do
      visit admin_media_tag_path(tag)

      expect(page).to have_content("Keine Medien mit diesem Tag vorhanden")
    end

    it "displays tag slug and creation date" do
      visit admin_media_tag_path(tag)

      expect(page).to have_content(tag.slug)
    end
  end

  describe "deleting a media tag" do
    let!(:tag) { create(:media_tag, name: "Tag to Delete") }

    it "removes tag from the list after deletion" do
      visit admin_media_tags_path

      expect(page).to have_content("Tag to Delete")

      within("[data-testid='media-tag-row-#{tag.id}']") do
        click_button "Löschen"
      end

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Tag wurde erfolgreich gelöscht")
      expect(page).to have_no_content("Tag to Delete")
    end
  end

  describe "navigation" do
    it "shows media tags link in admin navigation" do
      visit admin_root_path

      expect(page).to have_link("Tags", href: admin_media_tags_path)
    end

    it "can navigate from tag show page back to index" do
      tag = create(:media_tag, name: "Test Tag")

      visit admin_media_tag_path(tag)
      click_link "Zurück zur Übersicht"

      expect(page).to have_selector("[data-testid='admin-media-tags']")
    end
  end
end
