require "rails_helper"

RSpec.describe "Admin Artists" do
  let(:admin) { create(:user, :admin) }

  before do
    visit new_session_path
    fill_in "Email address", with: admin.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  describe "artists listing" do
    it "displays the artists index page" do
      visit admin_artists_path

      expect(page).to have_selector("[data-testid='admin-artists']")
      expect(page).to have_selector("[data-testid='artists-heading']", text: "Kunstschaffende")
    end

    it "shows existing artists" do
      create(:artist, created_by: admin, name: "Carl Hans Schrader")
      visit admin_artists_path

      expect(page).to have_content("Carl Hans Schrader")
    end

    it "shows no artists message when empty" do
      visit admin_artists_path

      expect(page).to have_selector("[data-testid='no-artists-message']")
    end

    it "allows filtering by status" do
      create(:artist, created_by: admin, name: "Draft Artist", status: "draft")
      create(:artist, :published, created_by: admin, name: "Published Artist")

      visit admin_artists_path
      select "Veröffentlicht", from: "status"
      click_button "Filtern"

      expect(page).to have_content("Published Artist")
      expect(page).to have_no_content("Draft Artist")
    end

    it "allows searching by name" do
      create(:artist, created_by: admin, name: "Hans Maler")
      create(:artist, created_by: admin, name: "Peter Bildhauer")

      visit admin_artists_path
      fill_in "q", with: "Maler"
      click_button "Filtern"

      expect(page).to have_content("Hans Maler")
      expect(page).to have_no_content("Peter Bildhauer")
    end
  end

  describe "creating an artist" do
    it "allows creating a new draft artist" do
      visit admin_artists_path
      click_link "Neuer Künstler", match: :first

      expect(page).to have_selector("[data-testid='admin-artists-new']")

      fill_in "Name", with: "New Test Artist"
      click_button "Künstler erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Künstler wurde erfolgreich erstellt")
      expect(page).to have_selector("[data-testid='artist-name']", text: "New Test Artist")
    end

    it "shows validation errors for invalid artist" do
      visit new_admin_artist_path

      click_button "Künstler erstellen"

      expect(page).to have_content("muss ausgefüllt werden")
    end

    it "allows setting life dates" do
      visit new_admin_artist_path

      fill_in "Name", with: "Artist with Dates"
      fill_in "Geburtsdatum", with: "1876-03-15"
      fill_in "Geburtsort", with: "Hannover"
      fill_in "Todesdatum", with: "1945-08-20"
      fill_in "Sterbeort", with: "Wartenberg"
      click_button "Künstler erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Künstler wurde erfolgreich erstellt")
      expect(page).to have_content("Hannover")
      expect(page).to have_content("Wartenberg")
    end
  end

  describe "editing an artist" do
    let!(:artist) { create(:artist, created_by: admin, name: "Original Name") }

    it "allows editing an existing artist" do
      visit admin_artists_path
      click_link "Bearbeiten"

      expect(page).to have_selector("[data-testid='admin-artists-edit']")

      fill_in "Name", with: "Updated Name"
      click_button "Künstler speichern"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Künstler wurde erfolgreich aktualisiert")
      expect(page).to have_selector("[data-testid='artist-name']", text: "Updated Name")
    end
  end

  describe "viewing an artist" do
    let!(:artist) { create(:artist, :published, created_by: admin, name: "Test Artist") }

    it "displays the artist details" do
      visit admin_artist_path(artist)

      expect(page).to have_selector("[data-testid='admin-artist-show']")
      expect(page).to have_selector("[data-testid='artist-name']", text: "Test Artist")
    end
  end

  describe "publishing and unpublishing" do
    let!(:draft_artist) { create(:artist, created_by: admin, name: "Draft Artist") }
    let!(:published_artist) { create(:artist, :published, created_by: admin, name: "Published Artist") }

    it "allows publishing a draft artist" do
      visit admin_artist_path(draft_artist)

      click_button "Veröffentlichen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Künstler wurde veröffentlicht")
      expect(page).to have_selector(".badge.bg-success", text: "Veröffentlicht")
    end

    it "allows unpublishing a published artist" do
      visit admin_artist_path(published_artist)

      click_button "Veröffentlichung zurückziehen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Veröffentlichung wurde zurückgezogen")
      expect(page).to have_selector(".badge.bg-secondary", text: "Entwurf")
    end
  end

  describe "deleting an artist" do
    let!(:artist) { create(:artist, created_by: admin, name: "Artist to Delete") }

    it "removes artist from the list after deletion" do
      visit admin_artists_path

      expect(page).to have_content("Artist to Delete")

      page.find("[data-testid='delete-artist-#{artist.slug}']").click

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Künstler wurde erfolgreich gelöscht")
      expect(page).to have_no_content("Artist to Delete")
    end
  end

  describe "navigation" do
    it "shows artists link in admin navigation" do
      visit admin_root_path

      expect(page).to have_link("Kunstschaffende", href: admin_artists_path)
    end
  end
end
