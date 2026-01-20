require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability do
  describe "guest user (nil)" do
    subject(:ability) { described_class.new(nil) }

    it "cannot read dashboard" do
      expect(ability).not_to be_able_to(:read, :dashboard)
    end

    it "cannot manage users" do
      expect(ability).not_to be_able_to(:manage, User)
    end

    it "can read published articles" do
      published_article = build(:article, :published)
      expect(ability).to be_able_to(:read, published_article)
    end

    it "cannot read draft articles" do
      draft_article = build(:article, status: "draft")
      expect(ability).not_to be_able_to(:read, draft_article)
    end

    it "cannot manage articles" do
      expect(ability).not_to be_able_to(:manage, Article)
    end

    it "cannot access admin area" do
      expect(ability).not_to be_able_to(:manage, :admin_area)
    end
  end

  describe "regular user" do
    let(:user) { create(:user, role: "user") }
    let(:other_user) { create(:user) }

    subject(:ability) { described_class.new(user) }

    it "can access admin area" do
      expect(ability).to be_able_to(:manage, :admin_area)
    end

    it "can read own profile" do
      expect(ability).to be_able_to(:read, user)
    end

    it "can update own profile" do
      expect(ability).to be_able_to(:update, user)
    end

    it "cannot read other users" do
      expect(ability).not_to be_able_to(:read, other_user)
    end

    it "cannot update other users" do
      expect(ability).not_to be_able_to(:update, other_user)
    end

    it "cannot manage content" do
      expect(ability).not_to be_able_to(:manage, :content)
    end

    it "cannot manage articles" do
      expect(ability).not_to be_able_to(:manage, Article)
    end
  end

  describe "editor" do
    let(:editor) { create(:user, :editor) }
    let(:other_user) { create(:user) }

    subject(:ability) { described_class.new(editor) }

    it "can access admin area" do
      expect(ability).to be_able_to(:manage, :admin_area)
    end

    it "can manage content" do
      expect(ability).to be_able_to(:manage, :content)
    end

    it "can read own profile" do
      expect(ability).to be_able_to(:read, editor)
    end

    it "can update own profile" do
      expect(ability).to be_able_to(:update, editor)
    end

    it "cannot manage all" do
      expect(ability).not_to be_able_to(:manage, :all)
    end

    it "can manage admin area" do
      expect(ability).to be_able_to(:manage, :admin_area)
    end

    it "can manage articles" do
      expect(ability).to be_able_to(:manage, Article)
    end
  end

  describe "admin" do
    let(:admin) { create(:user, :admin) }
    let(:other_user) { create(:user) }

    subject(:ability) { described_class.new(admin) }

    it "can manage all" do
      expect(ability).to be_able_to(:manage, :all)
    end

    it "can read dashboard" do
      expect(ability).to be_able_to(:read, :dashboard)
    end

    it "can manage users" do
      expect(ability).to be_able_to(:manage, User)
    end

    it "can manage other users" do
      expect(ability).to be_able_to(:manage, other_user)
    end

    it "can manage content" do
      expect(ability).to be_able_to(:manage, :content)
    end

    it "can manage admin area" do
      expect(ability).to be_able_to(:manage, :admin_area)
    end

    it "can manage articles" do
      expect(ability).to be_able_to(:manage, Article)
    end
  end
end
