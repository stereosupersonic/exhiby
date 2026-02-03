require "capybara_helper"

RSpec.describe "Admin Dashboard", type: :system do
  let(:admin) { create(:user, :admin) }

  before do
    visit new_session_path
    fill_in "Email address", with: admin.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  describe "dashboard page" do
    it "displays the dashboard" do
      visit admin_root_path

      expect(page).to have_selector("[data-testid='admin-dashboard']")
      expect(page).to have_selector("[data-testid='dashboard-heading']", text: "Dashboard")
    end

    it "displays quick action buttons" do
      visit admin_root_path

      expect(page).to have_link(href: new_admin_media_item_path)
      expect(page).to have_link(href: new_admin_article_path)
      expect(page).to have_link(href: new_admin_artist_path)
      expect(page).to have_link(href: new_admin_collection_path)
    end
  end

  describe "statistics cards" do
    before do
      create_list(:media_item, 3, :published, uploaded_by: admin)
      create_list(:media_item, 2, status: "draft", uploaded_by: admin)
      create_list(:media_item, 1, status: "pending_review", uploaded_by: admin)
      create_list(:article, 2, :published, author: admin)
      create_list(:artist, 2, :published, created_by: admin)
      create(:collection, :published, created_by: admin)
    end

    it "displays media items count" do
      visit admin_root_path

      expect(page).to have_content("6") # Total media items
    end

    it "displays published media items count" do
      visit admin_root_path

      expect(page).to have_content("3") # Published media items
    end

    it "displays articles statistics" do
      visit admin_root_path

      expect(page).to have_content("2") # Published articles
    end

    it "displays artists statistics" do
      visit admin_root_path

      expect(page).to have_content("2") # Published artists
    end

    it "links to media items with filters" do
      visit admin_root_path

      expect(page).to have_link(href: admin_media_items_path)
      expect(page).to have_link(href: admin_media_items_path(status: "draft"))
      expect(page).to have_link(href: admin_media_items_path(status: "pending_review"))
      expect(page).to have_link(href: admin_media_items_path(status: "published"))
    end
  end

  describe "pending review section" do
    it "shows pending review items when they exist" do
      create(:media_item, status: "pending_review", uploaded_by: admin, title: "Pending Image")

      visit admin_root_path

      expect(page).to have_content("Pending Image")
    end

    it "does not show pending section when no items pending" do
      visit admin_root_path

      expect(page).to have_no_content("Zur Überprüfung")
    end
  end

  describe "recent media items section" do
    it "shows recent media items" do
      create(:media_item, uploaded_by: admin, title: "Recent Upload")

      visit admin_root_path

      expect(page).to have_content("Recent Upload")
    end

    it "links to all media items" do
      create(:media_item, uploaded_by: admin)

      visit admin_root_path

      expect(page).to have_link(href: admin_media_items_path)
    end
  end

  describe "navigation links" do
    it "provides links to manage users" do
      visit admin_root_path

      expect(page).to have_link(href: admin_users_path)
    end

    it "provides links to manage tags" do
      visit admin_root_path

      expect(page).to have_link(href: admin_media_tags_path)
    end

    it "provides links to manage collection categories" do
      visit admin_root_path

      expect(page).to have_link(href: admin_collection_categories_path)
    end
  end
end
