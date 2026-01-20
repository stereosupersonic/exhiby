# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE), not null
#  email_address   :string           not null
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
FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password" }
    role { "user" }

    trait :admin do
      role { "admin" }
    end

    trait :editor do
      role { "editor" }
    end
  end
end
