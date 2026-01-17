require "rails_helper"

RSpec.describe "Authentication" do
  describe "sign in" do
    let!(:user) { create(:user, :admin, email_address: "admin@example.com", password: "password") }

    it "allows user to sign in with valid credentials" do
      visit new_session_path

      fill_in "Email address", with: "admin@example.com"
      fill_in "Password", with: "password"
      click_button "Sign In"

      expect(page).to have_current_path(root_path)
      expect(page).to have_selector("[data-testid='dashboard-heading']", text: "Dashboard")
      expect(page).to have_selector("[data-testid='user-email']", text: "admin@example.com")
    end

    it "shows error with invalid credentials" do
      visit new_session_path

      fill_in "Email address", with: "admin@example.com"
      fill_in "Password", with: "wrongpassword"
      click_button "Sign In"

      expect(page).to have_current_path(new_session_path)
      expect(page).to have_selector("[data-testid='flash-alert']")
    end

    it "shows error with non-existent user" do
      visit new_session_path

      fill_in "Email address", with: "nonexistent@example.com"
      fill_in "Password", with: "password"
      click_button "Sign In"

      expect(page).to have_current_path(new_session_path)
      expect(page).to have_selector("[data-testid='flash-alert']")
    end
  end

  describe "sign out" do
    let!(:user) { create(:user, email_address: "user@example.com", password: "password") }

    it "allows user to sign out" do
      sign_in_as(user)

      expect(page).to have_current_path(root_path)

      click_button "Sign Out"

      expect(page).to have_current_path(new_session_path)
    end
  end

  describe "protected routes" do
    it "redirects unauthenticated users to login" do
      visit root_path
      expect(page).to have_current_path(new_session_path)
    end
  end

  describe "role display" do
    it "shows admin role badge for admin users" do
      admin = create(:user, :admin, email_address: "admin@example.com", password: "password")
      sign_in_as(admin)

      expect(page).to have_selector("[data-testid='user-role']", text: "admin")
    end

    it "shows editor role badge for editor users" do
      editor = create(:user, :editor, email_address: "editor@example.com", password: "password")
      sign_in_as(editor)

      expect(page).to have_selector("[data-testid='user-role']", text: "editor")
    end

    it "shows user role badge for regular users" do
      user = create(:user, email_address: "user@example.com", password: "password")
      sign_in_as(user)

      expect(page).to have_selector("[data-testid='user-role']", text: "user")
    end
  end
end
