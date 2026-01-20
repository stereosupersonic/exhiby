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

    context "with recent articles" do
      let!(:article_with_date) { create(:article, :published, title: "Article With Date") }
      let!(:article_without_date) { create(:article, status: "published", published_at: nil, title: "Article Without Date") }

      it "displays recent articles section" do
        visit root_path

        expect(page).to have_selector("[data-testid='recent-articles-section']")
        expect(page).to have_content("Aktuelles")
      end

      it "displays article with published_at date" do
        visit root_path

        within "[data-testid='recent-article-card-#{article_with_date.slug}']" do
          expect(page).to have_content("Article With Date")
          expect(page).to have_content(I18n.l(article_with_date.published_at, format: :short))
        end
      end

      it "displays article without published_at date" do
        visit root_path

        within "[data-testid='recent-article-card-#{article_without_date.slug}']" do
          expect(page).to have_content("Article Without Date")
          expect(page).not_to have_css(".text-muted", text: /\d{2}\.\d{2}\./)
        end
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

    context "when not authenticated" do
      it "displays login link in header" do
        visit root_path

        within "[data-testid='header-login']" do
          expect(page).to have_selector("[data-testid='login-link']", text: "Anmelden")
        end
      end

      it "navigates to sign in page when clicking login" do
        visit root_path

        click_link "Anmelden"

        expect(page).to have_current_path(new_session_path)
      end
    end

    context "when authenticated as admin" do
      let(:admin) { create(:user, :admin) }

      before do
        visit new_session_path
        fill_in "Email address", with: admin.email_address
        fill_in "Password", with: "password"
        click_button "Sign In"
      end

      it "displays admin and logout links in header" do
        visit root_path

        within "[data-testid='header-login']" do
          expect(page).to have_selector("[data-testid='admin-link']", text: "Admin")
          expect(page).to have_selector("[data-testid='logout-link']", text: "Abmelden")
        end
      end

      it "navigates to admin when clicking Admin link" do
        visit root_path

        click_link "Admin"

        expect(page).to have_current_path(admin_root_path)
      end
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
