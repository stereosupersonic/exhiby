require "capybara_helper"

RSpec.describe "Admin Profile", type: :system do
  let(:user) { create(:user, email_address: "user@example.com", password: "password") }

  before do
    visit new_session_path
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  describe "accessing profile" do
    it "shows profile link in navigation" do
      visit admin_root_path

      expect(page).to have_link(user.email_address, href: edit_admin_profile_path)
    end

    it "navigates to profile page when clicking on email" do
      visit admin_root_path
      click_link user.email_address

      expect(page).to have_current_path(edit_admin_profile_path)
      expect(page).to have_selector("[data-testid='admin-profile-edit']")
    end

    it "displays the profile form" do
      visit edit_admin_profile_path

      expect(page).to have_field("E-Mail-Adresse", disabled: true)
      expect(page).to have_field("Aktuelles Passwort")
      expect(page).to have_field("Neues Passwort")
      expect(page).to have_field("Passwort bestätigen")
    end
  end

  describe "changing password" do
    it "allows user to change password with correct current password" do
      visit edit_admin_profile_path

      fill_in "Aktuelles Passwort", with: "password"
      fill_in "Neues Passwort", with: "newpassword123"
      fill_in "Passwort bestätigen", with: "newpassword123"
      click_button "Passwort ändern"

      expect(page).to have_current_path(admin_root_path)
      expect(page).to have_selector("[data-testid='flash-notice']", text: "Ihr Passwort wurde erfolgreich geändert")

      # Verify new password works by logging out and back in
      click_button "Abmelden"
      visit new_session_path
      fill_in "Email address", with: user.email_address
      fill_in "Password", with: "newpassword123"
      click_button "Sign In"

      expect(page).to have_current_path(admin_root_path)
    end

    it "shows error with incorrect current password" do
      visit edit_admin_profile_path

      fill_in "Aktuelles Passwort", with: "wrongpassword"
      fill_in "Neues Passwort", with: "newpassword123"
      fill_in "Passwort bestätigen", with: "newpassword123"
      click_button "Passwort ändern"

      expect(page).to have_current_path(admin_profile_path)
      expect(page).to have_content("ist nicht korrekt")
    end

    it "shows error when passwords do not match" do
      visit edit_admin_profile_path

      fill_in "Aktuelles Passwort", with: "password"
      fill_in "Neues Passwort", with: "newpassword123"
      fill_in "Passwort bestätigen", with: "differentpassword"
      click_button "Passwort ändern"

      expect(page).to have_current_path(admin_profile_path)
      expect(page).to have_selector(".alert-danger")
    end

    it "allows cancelling and returning to dashboard" do
      visit edit_admin_profile_path

      click_link "Abbrechen"

      expect(page).to have_current_path(admin_root_path)
    end
  end
end
