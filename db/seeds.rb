# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# import other seeds run bin/rails runner "load Rails.root.join('db/seeds/generated_seeds.rb')"

# Default techniques (all environments)
techniques = [
  "Öl auf Leinwand",
  "Öl auf Holz",
  "Öl auf Malpappe",
  "Acryl",
  "Aquarell",
  "Tempera",
  "Pastell",
  "Bleistiftzeichnung",
  "Kohlezeichnung",
  "Tusche",
  "Mischtechnik",
  "Holzschnitt",
  "Radierung",
  "Lithografie",
  "Siebdruck",
  "Digitaldruck",
  "Bronze",
  "Marmor",
  "Holzskulptur",
  "Keramik",
  "Fotografie",
  "Silbergelatineabzug",
  "Sonstige"
]

techniques.each_with_index do |name, index|
  Technique.find_or_create_by!(name: name) do |t|
    t.position = index
  end
end
puts "Created #{Technique.count} techniques"


# Default admin user (all environments)
admin = User.find_or_create_by!(email_address: "admin@museum-wartenberg.de") do |user|
  user.password = ENV.fetch("ADMIN_PASSWORD")
  user.role = "admin"
end
puts "Created admin user: #{admin.email_address}"

# Development/test users
if Rails.env.development? || Rails.env.test?
  editor = User.find_or_create_by!(email_address: "editor@museum-wartenberg.de") do |user|
    user.password = "password"
    user.role = "editor"
  end
  puts "Created editor user: #{editor.email_address}"

  regular_user = User.find_or_create_by!(email_address: "user@museum-wartenberg.de") do |user|
    user.password = "password"
    user.role = "user"
  end
  puts "Created regular user: #{regular_user.email_address}"
end
