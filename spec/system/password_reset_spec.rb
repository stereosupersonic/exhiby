require "rails_helper"

RSpec.describe "Password Reset" do
  let(:user) { create(:user, email_address: "test@example.com") }

  describe "requesting password reset" do
    it "displays the password reset form" do
      visit new_password_path

      expect(page).to have_selector("[data-testid='password-reset-form']")
      expect(page).to have_content("Reset Password")
    end

    it "allows requesting a password reset" do
      visit new_password_path

      fill_in "Email address", with: user.email_address
      click_button "Send Reset Instructions"

      expect(page).to have_current_path(new_session_path)
      expect(page).to have_content("Password reset instructions sent")
    end

    it "shows success message even for non-existent email" do
      visit new_password_path

      fill_in "Email address", with: "nonexistent@example.com"
      click_button "Send Reset Instructions"

      expect(page).to have_current_path(new_session_path)
      expect(page).to have_content("Password reset instructions sent")
    end

    it "provides link back to sign in" do
      visit new_password_path

      expect(page).to have_link("Back to Sign In", href: new_session_path)
    end

    it "is accessible from sign in page" do
      visit new_session_path

      expect(page).to have_link(href: new_password_path)
    end
  end

  describe "resetting password with valid token" do
    let(:token) { user.password_reset_token }

    it "displays the password reset form" do
      visit edit_password_path(token: token)

      expect(page).to have_content("Set New Password")
      expect(page).to have_selector("[data-testid='password-input']")
      expect(page).to have_selector("[data-testid='password-confirmation-input']")
    end

    it "allows resetting the password" do
      visit edit_password_path(token: token)

      fill_in "New Password", with: "newpassword123"
      fill_in "Confirm New Password", with: "newpassword123"
      click_button "Update Password"

      expect(page).to have_current_path(new_session_path)
      expect(page).to have_content("Password has been reset")
    end

    it "shows error when passwords do not match" do
      visit edit_password_path(token: token)

      fill_in "New Password", with: "newpassword123"
      fill_in "Confirm New Password", with: "differentpassword"
      click_button "Update Password"

      expect(page).to have_content("Passwords did not match")
    end

    it "allows signing in with new password after reset" do
      visit edit_password_path(token: token)

      fill_in "New Password", with: "newpassword123"
      fill_in "Confirm New Password", with: "newpassword123"
      click_button "Update Password"

      fill_in "Email address", with: user.email_address
      fill_in "Password", with: "newpassword123"
      click_button "Sign In"

      expect(page).to have_current_path(admin_root_path)
    end
  end

  describe "resetting password with invalid token" do
    it "redirects to password reset request page" do
      visit edit_password_path(token: "invalid_token")

      expect(page).to have_current_path(new_password_path)
      expect(page).to have_content("Password reset link is invalid or has expired")
    end
  end
end
