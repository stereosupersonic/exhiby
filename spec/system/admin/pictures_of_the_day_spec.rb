require "rails_helper"

RSpec.describe "Admin Pictures of the Day" do
  let(:admin) { create(:user, :admin) }

  before do
    visit new_session_path
    fill_in "Email address", with: admin.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  describe "pictures of the day listing" do
    it "displays the pictures of the day index page" do
      visit admin_pictures_of_the_day_index_path

      expect(page).to have_selector("[data-testid='admin-pictures-of-the-day']")
      expect(page).to have_selector("[data-testid='pictures-of-the-day-heading']", text: "Bild des Tages")
    end

    it "shows existing pictures of the day" do
      picture = create(:picture_of_the_day)
      visit admin_pictures_of_the_day_index_path

      expect(page).to have_content(picture.media_item.title)
    end

    it "shows no pictures message when empty" do
      visit admin_pictures_of_the_day_index_path

      expect(page).to have_selector("[data-testid='no-pictures-message']")
    end

    describe "filters" do
      let!(:today_picture) { create(:picture_of_the_day, :today) }
      let!(:upcoming_picture) { create(:picture_of_the_day, display_date: 5.days.from_now) }
      let!(:past_picture) { create(:picture_of_the_day, display_date: 5.days.ago) }

      it "filters by today" do
        visit admin_pictures_of_the_day_index_path(filter: "today")

        expect(page).to have_selector("[data-testid='picture-row-#{today_picture.id}']")
        expect(page).to have_no_selector("[data-testid='picture-row-#{upcoming_picture.id}']")
        expect(page).to have_no_selector("[data-testid='picture-row-#{past_picture.id}']")
      end

      it "filters by upcoming" do
        visit admin_pictures_of_the_day_index_path(filter: "upcoming")

        expect(page).to have_selector("[data-testid='picture-row-#{upcoming_picture.id}']")
        expect(page).to have_no_selector("[data-testid='picture-row-#{today_picture.id}']")
        expect(page).to have_no_selector("[data-testid='picture-row-#{past_picture.id}']")
      end

      it "filters by past" do
        visit admin_pictures_of_the_day_index_path(filter: "past")

        expect(page).to have_selector("[data-testid='picture-row-#{past_picture.id}']")
        expect(page).to have_selector("[data-testid='picture-row-#{today_picture.id}']")
        expect(page).to have_no_selector("[data-testid='picture-row-#{upcoming_picture.id}']")
      end
    end
  end

  describe "creating a picture of the day" do
    let!(:media_item) { create(:media_item, :published, title: "Beautiful Image") }

    it "shows the new form" do
      visit new_admin_pictures_of_the_day_path

      expect(page).to have_selector("[data-testid='admin-pictures-of-the-day-new']")
      expect(page).to have_field("Anzeigedatum")
      expect(page).to have_field("Titel (optional)")
      expect(page).to have_field("Beschreibung (optional)")
    end

    it "shows validation errors for invalid picture" do
      visit new_admin_pictures_of_the_day_path

      click_button "Bild des Tages erstellen"

      expect(page).to have_content("muss ausgefüllt werden")
    end

    it "creates a picture of the day successfully", :js do
      visit new_admin_pictures_of_the_day_path

      # Set hidden field directly via JavaScript
      page.execute_script("document.querySelector('input[name=\"picture_of_the_day[media_item_id]\"]').value = '#{media_item.id}'")

      fill_in "Anzeigedatum", with: Date.current.strftime("%Y-%m-%d")
      fill_in "Titel (optional)", with: "Custom Caption"

      click_button "Bild des Tages erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Bild des Tages wurde erfolgreich erstellt")
      expect(page).to have_selector("[data-testid='picture-title']", text: "Custom Caption")
    end
  end

  describe "editing a picture of the day" do
    let!(:picture) { create(:picture_of_the_day, caption: "Original Caption") }

    it "allows editing an existing picture of the day" do
      visit admin_pictures_of_the_day_index_path
      click_link "Bearbeiten"

      expect(page).to have_selector("[data-testid='admin-pictures-of-the-day-edit']")

      fill_in "Titel (optional)", with: "Updated Caption"
      click_button "Bild des Tages speichern"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Bild des Tages wurde erfolgreich aktualisiert")
      expect(page).to have_selector("[data-testid='picture-title']", text: "Updated Caption")
    end
  end

  describe "viewing a picture of the day" do
    let!(:picture) { create(:picture_of_the_day, :with_caption, :with_description) }

    it "displays the picture details" do
      visit admin_pictures_of_the_day_path(picture)

      expect(page).to have_selector("[data-testid='admin-pictures-of-the-day-show']")
      expect(page).to have_selector("[data-testid='picture-title']", text: picture.caption)
      expect(page).to have_selector("[data-testid='display-date']")
    end
  end

  describe "deleting a picture of the day" do
    let!(:picture) { create(:picture_of_the_day, caption: "Picture to Delete") }

    it "removes picture from the list after deletion" do
      visit admin_pictures_of_the_day_index_path

      expect(page).to have_content("Picture to Delete")

      page.find("[data-testid='delete-picture-#{picture.id}']").click

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Bild des Tages wurde erfolgreich gelöscht")
      expect(page).to have_no_content("Picture to Delete")
    end
  end

  describe "navigation" do
    it "shows the pictures of the day link in the admin navigation" do
      visit admin_root_path

      expect(page).to have_link("Bild des Tages", href: admin_pictures_of_the_day_index_path)
    end
  end
end
