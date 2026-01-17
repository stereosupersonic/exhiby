require "rails_helper"

RSpec.describe "Sessions" do
  describe "GET /session/new" do
    it "renders the login form" do
      get new_session_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /session" do
    let!(:user) { create(:user, email_address: "test@example.com", password: "password") }

    context "with valid credentials" do
      it "creates a session and redirects" do
        post session_path, params: { email_address: "test@example.com", password: "password" }
        expect(response).to redirect_to(root_path)
      end

      it "creates a session record" do
        expect {
          post session_path, params: { email_address: "test@example.com", password: "password" }
        }.to change(Session, :count).by(1)
      end
    end

    context "with invalid credentials" do
      it "redirects back to login with alert" do
        post session_path, params: { email_address: "test@example.com", password: "wrong" }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to be_present
      end

      it "does not create a session" do
        expect {
          post session_path, params: { email_address: "test@example.com", password: "wrong" }
        }.not_to change(Session, :count)
      end
    end

    context "with non-existent user" do
      it "redirects back to login with alert" do
        post session_path, params: { email_address: "nonexistent@example.com", password: "password" }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "DELETE /session" do
    let!(:user) { create(:user) }

    before do
      sign_in(user)
    end

    it "destroys the session and redirects to login" do
      delete session_path
      expect(response).to redirect_to(new_session_path)
    end
  end
end
