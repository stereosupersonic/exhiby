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

  # Sample collections
  category = CollectionCategory.find_or_create_by!(name: "Geschichte") do |c|
    c.slug = "geschichte"
    c.position = 0
  end

  collections_data = [
    {
      name: "Historische Ansichten von Wartenberg",
      description: "Eine Sammlung historischer Postkarten und Fotografien, die das Ortsbild von Wartenberg im Wandel der Zeit dokumentieren. Von den ersten fotografischen Aufnahmen um 1900 bis zu den Veränderungen der Nachkriegszeit."
    },
    {
      name: "Kunsthandwerk aus der Region",
      description: "Entdecken Sie die vielfältige Tradition des regionalen Kunsthandwerks. Töpferei, Holzschnitzerei und Textilkunst zeugen von der Kreativität und dem handwerklichen Geschick der Menschen in und um Wartenberg."
    },
    {
      name: "Kirchliche Kunst und Architektur",
      description: "Die Kirchen und Kapellen der Gemeinde bergen bemerkenswerte Kunstschätze. Diese Sammlung zeigt Altäre, Skulpturen und Gemälde aus verschiedenen Epochen der sakralen Kunst in Wartenberg."
    },
    {
      name: "Leben auf dem Land",
      description: "Einblicke in den bäuerlichen Alltag vergangener Jahrhunderte. Werkzeuge, Trachten und Gebrauchsgegenstände erzählen Geschichten vom Leben und Arbeiten auf dem Land in der Region Wartenberg."
    },
    {
      name: "Wartenberger Persönlichkeiten",
      description: "Porträts und Dokumente bedeutender Persönlichkeiten, die in Wartenberg geboren wurden oder hier wirkten. Von Künstlern über Gelehrte bis hin zu Handwerkern, die das Ortsleben geprägt haben."
    }
  ]

  collections_data.each_with_index do |data, index|
    collection = Collection.find_or_create_by!(name: data[:name]) do |c|
      c.collection_category = category
      c.created_by = admin
      c.status = "published"
      c.published_at = Time.current
      c.position = index
      c.description = data[:description]
    end
    puts "Created collection: #{collection.name}"
  end
end
