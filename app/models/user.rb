# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  activated_at    :datetime
#  active          :boolean          default(TRUE), not null
#  deactivated_at  :datetime
#  email_address   :string           not null
#  last_login_at   :datetime
#  password_digest :string           not null
#  role            :string           default("user"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_active         (active)
#  index_users_on_email_address  (email_address) UNIQUE
#  index_users_on_role           (role)
#
class User < ApplicationRecord
  ROLES = %w[admin editor user].freeze

  attr_accessor :current_password

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :articles, foreign_key: :author_id, dependent: :destroy, inverse_of: :author
  has_many :uploaded_media_items, class_name: "MediaItem", foreign_key: :uploaded_by_id,
                                  dependent: :destroy, inverse_of: :uploaded_by
  has_many :reviewed_media_items, class_name: "MediaItem", foreign_key: :reviewed_by_id,
                                  dependent: :nullify, inverse_of: :reviewed_by
  has_many :created_artists, class_name: "Artist", foreign_key: :created_by_id,
                             dependent: :destroy, inverse_of: :created_by
  has_many :created_collections, class_name: "Collection", foreign_key: :created_by_id,
                                 dependent: :destroy, inverse_of: :created_by

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: ROLES }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def deactivate!
    update!(active: false, deactivated_at: Time.current)
  end

  def activate!
    update!(active: true, activated_at: Time.current)
  end

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
