require "rails_helper"

RSpec.describe UserPresenter do
  let(:user) { create(:user, created_at: Time.zone.local(2024, 3, 15, 10, 30)) }
  let(:presenter) { described_class.new(user) }

  describe "#role_badge_class" do
    context "when user is admin" do
      let(:user) { build(:user, :admin) }

      it "returns danger class" do
        expect(presenter.role_badge_class).to eq("bg-danger")
      end
    end

    context "when user is editor" do
      let(:user) { build(:user, :editor) }

      it "returns primary class" do
        expect(presenter.role_badge_class).to eq("bg-primary")
      end
    end

    context "when user is regular user" do
      let(:user) { build(:user, role: "user") }

      it "returns secondary class" do
        expect(presenter.role_badge_class).to eq("bg-secondary")
      end
    end
  end

  describe "#status_badge_class" do
    context "when user is active" do
      let(:user) { build(:user, active: true) }

      it "returns success class" do
        expect(presenter.status_badge_class).to eq("bg-success")
      end
    end

    context "when user is inactive" do
      let(:user) { build(:user, active: false) }

      it "returns secondary class" do
        expect(presenter.status_badge_class).to eq("bg-secondary")
      end
    end
  end

  describe "#status_name" do
    context "when user is active" do
      let(:user) { build(:user, active: true) }

      it "returns translated status name" do
        expect(presenter.status_name).to eq("Aktiv")
      end
    end

    context "when user is inactive" do
      let(:user) { build(:user, active: false) }

      it "returns translated status name" do
        expect(presenter.status_name).to eq("Inaktiv")
      end
    end
  end

  describe "#role_name" do
    context "when user is admin" do
      let(:user) { build(:user, :admin) }

      it "returns translated role name" do
        expect(presenter.role_name).to eq("Administrator")
      end
    end

    context "when user is editor" do
      let(:user) { build(:user, :editor) }

      it "returns translated role name" do
        expect(presenter.role_name).to eq("Redakteur")
      end
    end

    context "when user is regular user" do
      let(:user) { build(:user, role: "user") }

      it "returns translated role name" do
        expect(presenter.role_name).to eq("Benutzer")
      end
    end
  end

  describe "#formatted_created_at" do
    it "returns formatted date in long format" do
      expect(presenter.formatted_created_at).to eq("15. März 2024 um 10:30 Uhr")
    end
  end

  describe "#formatted_created_at_short" do
    it "returns formatted date in short format" do
      expect(presenter.formatted_created_at_short).to eq("15.03. 10:30")
    end
  end

  describe "#articles_count" do
    context "when user has no articles" do
      it "returns zero" do
        expect(presenter.articles_count).to eq(0)
      end
    end

    context "when user has articles" do
      before do
        create_list(:article, 3, author: user)
      end

      it "returns the count of articles" do
        expect(presenter.articles_count).to eq(3)
      end
    end
  end

  describe "delegation" do
    it "delegates missing methods to the wrapped object" do
      expect(presenter.email_address).to eq(user.email_address)
      expect(presenter.role).to eq(user.role)
    end
  end
end
