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
