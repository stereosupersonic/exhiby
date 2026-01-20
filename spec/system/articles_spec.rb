require "rails_helper"

RSpec.describe "Public Articles" do
  describe "articles listing" do
    it "displays the articles index page" do
      visit articles_path

      expect(page).to have_selector("[data-testid='articles-section']")
      expect(page).to have_selector("[data-testid='articles-heading']", text: "Aktuelles")
    end

    it "displays published articles" do
      create(:article, :published, title: "Published Article")
      visit articles_path

      expect(page).to have_content("Published Article")
    end

    it "does not display draft articles" do
      create(:article, status: "draft", title: "Draft Article")
      visit articles_path

      expect(page).to have_no_content("Draft Article")
    end

    it "shows no articles message when empty" do
      visit articles_path

      expect(page).to have_selector("[data-testid='no-articles-message']")
      expect(page).to have_content("Keine Artikel vorhanden")
    end

    it "links to individual articles" do
      create(:article, :published, title: "Test Article")
      visit articles_path

      click_link "Weiterlesen"

      expect(page).to have_selector("[data-testid='article-section']")
      expect(page).to have_selector("[data-testid='article-title']", text: "Test Article")
    end
  end

  describe "viewing an article" do
    let!(:article) { create(:article, :published, title: "Test Article") }

    it "displays the article content" do
      visit article_path(article.slug)

      expect(page).to have_selector("[data-testid='article-section']")
      expect(page).to have_selector("[data-testid='article-title']", text: "Test Article")
      expect(page).to have_selector("[data-testid='article-body']")
    end

    it "displays the publication date" do
      visit article_path(article.slug)

      expect(page).to have_selector("[data-testid='article-published-at']")
    end

    it "has a back link to articles listing" do
      visit article_path(article.slug)

      first(:link, "Zurück zur Übersicht").click

      expect(page).to have_selector("[data-testid='articles-section']")
    end
  end

  describe "navigation" do
    it "has Aktuelles link in navigation" do
      visit articles_path

      expect(page).to have_selector("[data-testid='nav-aktuelles']")
    end
  end
end
