require "rails_helper"

RSpec.describe "Pictures of the Day" do
  describe "archive page" do
    it "displays the archive page" do
      visit pictures_of_the_day_path

      expect(page).to have_selector("[data-testid='pictures-of-the-day-archive']")
      expect(page).to have_content("Bild des Tages - Archiv")
    end

    it "shows past pictures of the day" do
      picture = create(:picture_of_the_day, display_date: 2.days.ago)
      visit pictures_of_the_day_path

      expect(page).to have_selector("[data-testid='picture-card-#{picture.display_date}']")
      expect(page).to have_content(picture.display_title)
    end

    it "does not show upcoming pictures" do
      past_picture = create(:picture_of_the_day, display_date: 2.days.ago)
      upcoming_picture = create(:picture_of_the_day, display_date: 2.days.from_now)

      visit pictures_of_the_day_path

      expect(page).to have_selector("[data-testid='picture-card-#{past_picture.display_date}']")
      expect(page).to have_no_content(upcoming_picture.display_title)
    end

    it "shows no pictures message when empty" do
      visit pictures_of_the_day_path

      expect(page).to have_selector("[data-testid='no-pictures-message']")
    end
  end

  describe "show page" do
    let!(:picture) { create(:picture_of_the_day, display_date: 2.days.ago, caption: "Beautiful Sunset") }

    it "displays the picture details" do
      visit picture_of_the_day_path(date: picture.display_date)

      expect(page).to have_selector("[data-testid='picture-of-the-day-show']")
      expect(page).to have_selector("[data-testid='picture-title']", text: "Beautiful Sunset")
      expect(page).to have_selector("[data-testid='display-date']")
    end

    it "displays the back link" do
      visit picture_of_the_day_path(date: picture.display_date)

      expect(page).to have_link("Zurück zum Archiv", href: pictures_of_the_day_path)
    end

    it "redirects to archive for non-existent dates" do
      visit picture_of_the_day_path(date: "2020-01-01")

      expect(page).to have_current_path(pictures_of_the_day_path)
      expect(page).to have_selector(".alert", text: "Für dieses Datum gibt es kein Bild des Tages")
    end
  end

  describe "navigation" do
    it "shows the active nav state on archive page" do
      visit pictures_of_the_day_path

      expect(page).to have_selector("[data-testid='nav-bild-des-tages'].active")
    end

    it "links to the archive from the main navigation" do
      visit root_path

      expect(page).to have_link("Bild des Tages", href: pictures_of_the_day_path)
    end
  end
end
