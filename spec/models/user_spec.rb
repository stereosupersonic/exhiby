# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email_address   :string           not null
#  password_digest :string           not null
#  role            :string           default("user"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#  index_users_on_role           (role)
#
require "rails_helper"

RSpec.describe User do
  describe "associations" do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_uniqueness_of(:email_address).case_insensitive }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_inclusion_of(:role).in_array(User::ROLES) }

    it "validates email format" do
      user = build(:user, email_address: "invalid-email")
      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to be_present
    end

    it "accepts valid email format" do
      user = build(:user, email_address: "valid@example.com")
      expect(user).to be_valid
    end
  end

  describe "secure password" do
    it { is_expected.to have_secure_password }
  end

  describe "normalizations" do
    it "normalizes email address to lowercase and strips whitespace" do
      user = create(:user, email_address: "  TEST@EXAMPLE.COM  ")
      expect(user.email_address).to eq("test@example.com")
    end
  end

  describe "role methods" do
    describe "#admin?" do
      it "returns true for admin role" do
        user = build(:user, :admin)
        expect(user.admin?).to be true
      end

      it "returns false for non-admin role" do
        user = build(:user, role: "user")
        expect(user.admin?).to be false
      end
    end

    describe "#editor?" do
      it "returns true for editor role" do
        user = build(:user, :editor)
        expect(user.editor?).to be true
      end

      it "returns false for non-editor role" do
        user = build(:user, role: "user")
        expect(user.editor?).to be false
      end
    end

    describe "#user?" do
      it "returns true for user role" do
        user = build(:user, role: "user")
        expect(user.user?).to be true
      end

      it "returns false for non-user role" do
        user = build(:user, :admin)
        expect(user.user?).to be false
      end
    end
  end

  describe "constants" do
    it "defines ROLES" do
      expect(User::ROLES).to eq(%w[admin editor user])
    end
  end
end
