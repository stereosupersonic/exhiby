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
class User < ApplicationRecord
  ROLES = %w[admin editor user].freeze

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :articles, foreign_key: :author_id, dependent: :destroy, inverse_of: :author

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: ROLES }

  def admin?
    role == "admin"
  end

  def editor?
    role == "editor"
  end

  def user?
    role == "user"
  end
end
