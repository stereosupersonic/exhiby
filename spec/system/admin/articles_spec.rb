require "rails_helper"

RSpec.describe "Admin Articles" do
  let(:admin) { create(:user, :admin) }

  before do
    visit new_session_path
    fill_in "Email address", with: admin.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  describe "articles listing" do
    it "displays the articles index page" do
      visit admin_articles_path

      expect(page).to have_selector("[data-testid='admin-articles']")
      expect(page).to have_selector("[data-testid='articles-heading']", text: "Artikel")
    end

    it "shows existing articles" do
      create(:article, author: admin, title: "Test Article")
      visit admin_articles_path

      expect(page).to have_content("Test Article")
    end

    it "shows no articles message when empty" do
      visit admin_articles_path

      expect(page).to have_selector("[data-testid='no-articles-message']")
    end
  end

  describe "creating an article" do
    it "allows creating a new draft article" do
      visit admin_articles_path
      click_link "Neuer Artikel", match: :first

      expect(page).to have_selector("[data-testid='admin-articles-new']")

      fill_in "Titel", with: "My New Article"
      click_button "Artikel erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Artikel wurde erfolgreich erstellt")
      expect(page).to have_selector("[data-testid='article-title']", text: "My New Article")
    end

    it "shows validation errors for invalid article" do
      visit new_admin_article_path

      click_button "Artikel erstellen"

      expect(page).to have_content("muss ausgefüllt werden")
    end
  end

  describe "editing an article" do
    let!(:article) { create(:article, author: admin, title: "Original Title") }

    it "allows editing an existing article" do
      visit admin_articles_path
      click_link "Bearbeiten"

      expect(page).to have_selector("[data-testid='admin-articles-edit']")

      fill_in "Titel", with: "Updated Title"
      click_button "Artikel speichern"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Artikel wurde erfolgreich aktualisiert")
      expect(page).to have_selector("[data-testid='article-title']", text: "Updated Title")
    end
  end

  describe "viewing an article" do
    let!(:article) { create(:article, :published, author: admin, title: "Test Article") }

    it "displays the article details" do
      visit admin_article_path(article)

      expect(page).to have_selector("[data-testid='admin-articles-show']")
      expect(page).to have_selector("[data-testid='article-title']", text: "Test Article")
    end
  end

  describe "deleting an article" do
    let!(:article) { create(:article, author: admin, title: "Article to Delete", slug: "article-to-delete") }

    it "removes article from the list after deletion" do
      visit admin_articles_path

      expect(page).to have_content("Article to Delete")

      # Delete without JS confirmation (turbo handles it without confirmation in test driver)
      page.find("[data-testid='delete-article-article-to-delete']").click

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Artikel wurde erfolgreich gelöscht")
      expect(page).to have_no_content("Article to Delete")
    end
  end
end
