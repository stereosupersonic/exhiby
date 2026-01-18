require "rails_helper"

RSpec.describe "Welcome Pages" do
  describe "start page" do
    it "displays the homepage with all sections" do
      visit root_path

      expect(page).to have_selector("[data-testid='site-header']")
      expect(page).to have_selector("[data-testid='main-navigation']")
      expect(page).to have_selector("[data-testid='hero-section']")
      expect(page).to have_selector("[data-testid='welcome-section']")
    end

    it "displays the logo in the header" do
      visit root_path

      within "[data-testid='site-header']" do
        expect(page).to have_selector("[data-testid='logo-link']")
        expect(page).to have_css("img[alt='OnlineMuseum Wartenberg Logo']")
      end
    end

    it "displays the hero section with title" do
      visit root_path

      within "[data-testid='hero-section']" do
        expect(page).to have_css("h1", text: "OnlineMuseum Wartenberg")
        expect(page).to have_content("ein Ort für Kunst und Kulturgeschichte")
      end
    end

    it "displays the main navigation with all links" do
      visit root_path

      within "[data-testid='main-navigation']" do
        expect(page).to have_selector("[data-testid='nav-willkommen']", text: "Willkommen")
        expect(page).to have_selector("[data-testid='nav-kunstschaffende']", text: "Kunstschaffende")
        expect(page).to have_selector("[data-testid='nav-land-leute']", text: "Land & Leute")
        expect(page).to have_selector("[data-testid='nav-ausstellungen']", text: "Ausstellungen")
        expect(page).to have_selector("[data-testid='nav-team']", text: "Team")
        expect(page).to have_selector("[data-testid='nav-bild-der-woche']", text: "Bild der Woche")
        expect(page).to have_selector("[data-testid='nav-presseberichte']", text: "Presseberichte")
        expect(page).to have_selector("[data-testid='nav-archiv']", text: "Archiv")
      end
    end

    it "displays the welcome content section" do
      visit root_path

      within "[data-testid='welcome-section']" do
        expect(page).to have_css("h2", text: "Über uns")
        expect(page).to have_content("Entdeckungsreise")
      end
    end

    it "displays footer with legal links" do
      visit root_path

      within ".site-footer" do
        expect(page).to have_link("Impressum", href: impressum_path)
        expect(page).to have_link("Datenschutzerklärung", href: datenschutzerklaerung_path)
      end
    end

    it "navigates to impressum page from footer" do
      visit root_path

      within ".site-footer" do
        click_link "Impressum"
      end

      expect(page).to have_current_path(impressum_path)
      expect(page).to have_selector("[data-testid='impressum-page']")
    end

    it "navigates to datenschutz page from footer" do
      visit root_path

      within ".site-footer" do
        click_link "Datenschutzerklärung"
      end

      expect(page).to have_current_path(datenschutzerklaerung_path)
      expect(page).to have_selector("[data-testid='datenschutz-page']")
    end
  end

  describe "impressum page" do
    it "displays the impressum content" do
      visit impressum_path

      expect(page).to have_selector("[data-testid='impressum-page']")
      expect(page).to have_selector("[data-testid='impressum-title']", text: "Impressum")
      expect(page).to have_content("Angaben gemäß § 5 TMG")
      expect(page).to have_content("OnlineMuseum Wartenberg")
      expect(page).to have_content("Marktplatz 1")
      expect(page).to have_content("85456 Wartenberg")
    end

    it "displays footer links" do
      visit impressum_path

      within ".site-footer" do
        expect(page).to have_link("Impressum")
        expect(page).to have_link("Datenschutzerklärung")
      end
    end
  end

  describe "datenschutzerklaerung page" do
    it "displays the privacy policy content" do
      visit datenschutzerklaerung_path

      expect(page).to have_selector("[data-testid='datenschutz-page']")
      expect(page).to have_selector("[data-testid='datenschutz-title']", text: "Datenschutzerklärung")
      expect(page).to have_content("Datenschutz auf einen Blick")
      expect(page).to have_content("personenbezogenen Daten")
    end

    it "displays footer links" do
      visit datenschutzerklaerung_path

      within ".site-footer" do
        expect(page).to have_link("Impressum")
        expect(page).to have_link("Datenschutzerklärung")
      end
    end
  end
end
