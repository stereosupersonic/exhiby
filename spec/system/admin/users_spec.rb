require "capybara_helper"

RSpec.describe "Admin Users", type: :system do
  let(:admin) { create(:user, :admin) }

  before do
    visit new_session_path
    fill_in "Email address", with: admin.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  describe "users listing" do
    it "displays the users index page" do
      visit admin_users_path

      expect(page).to have_selector("[data-testid='admin-users']")
      expect(page).to have_selector("[data-testid='users-heading']", text: "Benutzer")
    end

    it "shows existing users" do
      create(:user, email_address: "test@example.com")
      visit admin_users_path

      expect(page).to have_content("test@example.com")
    end

    it "shows the current admin user" do
      visit admin_users_path

      expect(page).to have_content(admin.email_address)
    end

    it "displays user roles with badges" do
      create(:user, :editor, email_address: "editor@example.com")
      visit admin_users_path

      expect(page).to have_content("Redakteur")
    end
  end

  describe "creating a user" do
    it "shows new user button on index page" do
      visit admin_users_path

      expect(page).to have_link("Neuer Benutzer", href: new_admin_user_path)
    end

    it "allows creating a new user" do
      visit admin_users_path
      click_link "Neuer Benutzer"

      expect(page).to have_selector("[data-testid='admin-users-new']")

      fill_in "E-Mail-Adresse", with: "newuser@example.com"
      fill_in "Passwort", with: "password123"
      fill_in "Passwort bestätigen", with: "password123"
      select "Redakteur", from: "Rolle"
      click_button "Benutzer erstellen"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Benutzer wurde erfolgreich erstellt")
      expect(page).to have_content("newuser@example.com")
    end

    it "shows validation errors for invalid user" do
      visit new_admin_user_path

      click_button "Benutzer erstellen"

      expect(page).to have_selector(".alert-danger")
    end

    it "shows error when passwords do not match" do
      visit new_admin_user_path

      fill_in "E-Mail-Adresse", with: "newuser@example.com"
      fill_in "Passwort", with: "password123"
      fill_in "Passwort bestätigen", with: "differentpassword"
      click_button "Benutzer erstellen"

      expect(page).to have_selector(".alert-danger")
    end
  end

  describe "editing a user" do
    let!(:user_to_edit) { create(:user, email_address: "user@example.com", role: "user") }

    it "allows editing an existing user" do
      visit admin_users_path

      within("[data-testid='user-row-#{user_to_edit.id}']") do
        click_link "Bearbeiten"
      end

      expect(page).to have_selector("[data-testid='admin-users-edit']")

      select "Redakteur", from: "Rolle"
      click_button "Benutzer speichern"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Benutzer wurde erfolgreich aktualisiert")
      expect(user_to_edit.reload.role).to eq("editor")
    end

    it "allows changing email address" do
      visit edit_admin_user_path(user_to_edit)

      fill_in "E-Mail-Adresse", with: "newemail@example.com"
      click_button "Benutzer speichern"

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Benutzer wurde erfolgreich aktualisiert")
      expect(user_to_edit.reload.email_address).to eq("newemail@example.com")
    end
  end

  describe "deactivating a user" do
    let!(:user_to_deactivate) { create(:user, email_address: "deactivate@example.com", active: true) }

    it "allows deactivating an existing user" do
      visit admin_users_path

      expect(page).to have_content("deactivate@example.com")

      page.find("[data-testid='deactivate-user-#{user_to_deactivate.id}']").click

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Benutzer wurde deaktiviert")
      expect(user_to_deactivate.reload).not_to be_active
    end

    it "does not show deactivate button for current user" do
      visit admin_users_path

      expect(page).to have_no_selector("[data-testid='deactivate-user-#{admin.id}']")
    end

    it "shows user status badges" do
      visit admin_users_path

      expect(page).to have_content("Aktiv")
    end
  end

  describe "activating a user" do
    let!(:inactive_user) { create(:user, email_address: "inactive@example.com", active: false) }

    it "allows activating an inactive user" do
      visit admin_users_path

      page.find("[data-testid='activate-user-#{inactive_user.id}']").click

      expect(page).to have_selector("[data-testid='flash-notice']", text: "Benutzer wurde aktiviert")
      expect(inactive_user.reload).to be_active
    end

    it "shows inactive status for deactivated users" do
      visit admin_users_path

      within("[data-testid='user-row-#{inactive_user.id}']") do
        expect(page).to have_content("Inaktiv")
      end
    end
  end

  describe "navigation" do
    it "shows users link in admin navigation for admins" do
      visit admin_root_path

      expect(page).to have_link("Benutzer", href: admin_users_path)
    end
  end

  describe "authorization" do
    context "when user is editor" do
      let(:editor) { create(:user, :editor) }

      it "does not show users link in navigation" do
        # Sign out current admin and sign in as editor
        Capybara.reset_sessions!
        visit new_session_path
        fill_in "Email address", with: editor.email_address
        fill_in "Password", with: "password"
        click_button "Sign In"

        visit admin_root_path

        expect(page).to have_no_link("Benutzer")
      end
    end
  end
end
