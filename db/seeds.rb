# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Default admin user (all environments)
admin = User.find_or_create_by!(email_address: "admin@exhiby.local") do |user|
  user.password = ENV.fetch("ADMIN_PASSWORD", "changeme123")
  user.role = "admin"
end
puts "Created admin user: #{admin.email_address}"

# Development/test users
if Rails.env.development? || Rails.env.test?
  editor = User.find_or_create_by!(email_address: "editor@exhiby.local") do |user|
    user.password = "password"
    user.role = "editor"
  end
  puts "Created editor user: #{editor.email_address}"

  regular_user = User.find_or_create_by!(email_address: "user@exhiby.local") do |user|
    user.password = "password"
    user.role = "user"
  end
  puts "Created regular user: #{regular_user.email_address}"
end
