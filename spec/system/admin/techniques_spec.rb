require "rails_helper"

RSpec.describe "Admin Techniques", type: :system do
  let(:admin) { create(:user, :admin) }

  before do
    visit new_session_path
    fill_in "Email address", with: admin.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  describe "techniques listing" do
    it "displays the techniques index page" do
      visit admin_techniques_path

      expect(page).to have_selector("[data-testid='admin-techniques']")
      expect(page).to have_selector("[data-testid='techniques-heading']", text: "Techniken")
    end

    it "shows existing techniques" do
      create(:technique, name: "Öl auf Leinwand")
      visit admin_techniques_path

      expect(page).to have_content("Öl auf Leinwand")
    end

    it "shows no techniques message when empty" do
      visit admin_techniques_path

      expect(page).to have_selector("[data-testid='no-techniques-message']")
    end

    it "displays techniques ordered by position and name" do
      create(:technique, name: "Bronze", position: 2)
      create(:technique, name: "Aquarell", position: 1)
      create(:technique, name: "Acryl", position: 1)

      visit admin_techniques_path

      rows = page.all("[data-testid^='technique-row-']")
      expect(rows[0]).to have_content("Acryl")
      expect(rows[1]).to have_content("Aquarell")
      expect(rows[2]).to have_content("Bronze")
    end

    it "shows the media items count for each technique" do
      technique = create(:technique, name: "Test Technique")
      create(:media_item, technique: technique)

      visit admin_techniques_path

      expect(page).to have_selector("[data-testid='technique-row-#{technique.slug}']", text: "1")
    end

    it "shows the position for each technique" do
      create(:technique, name: "Test Technique", position: 5)
      visit admin_techniques_path

      expect(page).to have_content("5")
    end
  end

  describe "creating a technique" do
    it "allows creating a new technique" do
      visit admin_techniques_path
      click_link "Neue Technik", match: :first

      expect(page).to have_selector("[data-testid='admin-techniques-new']")

      fill_in "Name", with: "Holzschnitt"
      click_button "Technik erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Technik wurde erfolgreich erstellt")
      expect(page).to have_content("Holzschnitt")
    end

    it "allows setting position when creating" do
      visit new_admin_technique_path

      fill_in "Name", with: "Test Technique"
      fill_in "Position", with: "10"
      click_button "Technik erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Technik wurde erfolgreich erstellt")

      technique = Technique.last
      expect(technique.position).to eq(10)
    end

    it "automatically generates slug from name" do
      visit new_admin_technique_path

      fill_in "Name", with: "Öl auf Holz"
      click_button "Technik erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']")
      expect(Technique.last.slug).to eq("ol-auf-holz")
    end

    it "shows validation errors for invalid technique" do
      visit new_admin_technique_path

      click_button "Technik erstellen"

      expect(page).to have_content("can't be blank").or have_content("muss ausgefüllt werden")
    end

    it "shows validation error for duplicate name" do
      create(:technique, name: "Existing Technique")

      visit new_admin_technique_path
      fill_in "Name", with: "Existing Technique"
      click_button "Technik erstellen"

      expect(page).to have_content("has already been taken").or have_content("ist bereits vergeben")
    end
  end

  describe "editing a technique" do
    let!(:technique) { create(:technique, name: "Original Name", position: 1) }

    it "allows editing an existing technique" do
      visit admin_techniques_path
      click_link "Bearbeiten"

      expect(page).to have_selector("[data-testid='admin-techniques-edit']")

      fill_in "Name", with: "Updated Name"
      click_button "Technik speichern"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Technik wurde erfolgreich aktualisiert")
      expect(page).to have_content("Updated Name")
    end

    it "allows updating the position" do
      visit edit_admin_technique_path(technique)

      fill_in "Position", with: "20"
      click_button "Technik speichern"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Technik wurde erfolgreich aktualisiert")
      expect(technique.reload.position).to eq(20)
    end

    it "updates slug when name changes" do
      visit edit_admin_technique_path(technique)

      fill_in "Name", with: "New Technique Name"
      click_button "Technik speichern"

      expect(technique.reload.slug).to eq("new-technique-name")
    end
  end

  describe "deleting a technique" do
    let!(:technique) { create(:technique, name: "Technique to Delete") }

    it "removes technique from the list after deletion" do
      visit admin_techniques_path

      expect(page).to have_content("Technique to Delete")

      page.find("[data-testid='delete-technique-#{technique.slug}']").click

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Technik wurde erfolgreich gelöscht")
      expect(page).to have_no_content("Technique to Delete")
    end

    it "nullifies technique reference on associated media items" do
      media_item = create(:media_item, technique: technique)

      visit admin_techniques_path
      page.find("[data-testid='delete-technique-#{technique.slug}']").click

      expect(media_item.reload.technique_id).to be_nil
    end
  end

  describe "navigation" do
    it "shows techniques link in admin navigation" do
      visit admin_root_path

      expect(page).to have_link("Techniken", href: admin_techniques_path)
    end
  end
end
