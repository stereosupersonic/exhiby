# Generated seeds from database export
# Generated at: 2026-01-21 14:35:09 UTC
#
# Usage: load Rails.root.join('db/seeds/generated_seeds.rb')

SEED_IMAGES_DIR = Rails.root.join("db/seeds/images")

def attach_file(record, attachment_name, filepath)
  full_path = SEED_IMAGES_DIR.join(filepath)
  return unless File.exist?(full_path)

  content_type = Marcel::MimeType.for(Pathname.new(full_path))
  record.public_send(attachment_name).attach(
    io: File.open(full_path),
    filename: File.basename(filepath),
    content_type: content_type
  )
end

puts "Loading generated seeds..."

# ============================================
# Users
# ============================================
users_data = [{:id=>2, :email_address=>"editor@exhiby.local", :role=>"editor", :password=>"password"}, {:id=>3, :email_address=>"user@exhiby.local", :role=>"user", :password=>"password"}, {:id=>1, :email_address=>"admin@exhiby.local", :role=>"admin", :password=>"password"}]

user_id_map = {}
users_data.each do |data|
  old_id = data.delete(:id)
  user = User.find_or_create_by!(email_address: data[:email_address]) do |u|
    u.password = data[:password] || "password"
    u.role = data[:role]
  end
  user_id_map[old_id] = user.id
end
puts "Created/found #{User.count} users"

# ============================================
# Techniques
# ============================================
techniques_data = [{:id=>1, :name=>"Öl auf Leinwand", :position=>0}, {:id=>2, :name=>"Öl auf Holz", :position=>1}, {:id=>3, :name=>"Öl auf Malpappe", :position=>2}, {:id=>4, :name=>"Acryl", :position=>3}, {:id=>5, :name=>"Aquarell", :position=>4}, {:id=>6, :name=>"Tempera", :position=>5}, {:id=>7, :name=>"Pastell", :position=>6}, {:id=>8, :name=>"Bleistiftzeichnung", :position=>7}, {:id=>9, :name=>"Kohlezeichnung", :position=>8}, {:id=>10, :name=>"Tusche", :position=>9}, {:id=>11, :name=>"Mischtechnik", :position=>10}, {:id=>12, :name=>"Holzschnitt", :position=>11}, {:id=>13, :name=>"Radierung", :position=>12}, {:id=>14, :name=>"Lithografie", :position=>13}, {:id=>15, :name=>"Siebdruck", :position=>14}, {:id=>16, :name=>"Digitaldruck", :position=>15}, {:id=>17, :name=>"Bronze", :position=>16}, {:id=>18, :name=>"Marmor", :position=>17}, {:id=>19, :name=>"Holzskulptur", :position=>18}, {:id=>20, :name=>"Keramik", :position=>19}, {:id=>21, :name=>"Fotografie", :position=>20}, {:id=>22, :name=>"Silbergelatineabzug", :position=>21}, {:id=>23, :name=>"Sonstige", :position=>22}]

technique_id_map = {}
techniques_data.each do |data|
  old_id = data.delete(:id)
  technique = Technique.find_or_create_by!(name: data[:name]) do |t|
    t.position = data[:position]
  end
  technique_id_map[old_id] = technique.id
end
puts "Created/found #{Technique.count} techniques"

# ============================================
# Media Tags
# ============================================
media_tags_data = [{:id=>1, :name=>"800-Jahrfeier"}, {:id=>2, :name=>"Umzug"}, {:id=>3, :name=>"hahn"}, {:id=>4, :name=>"tier"}, {:id=>5, :name=>"Postkarte"}]

media_tag_id_map = {}
media_tags_data.each do |data|
  old_id = data.delete(:id)
  tag = MediaTag.find_or_create_by!(name: data[:name])
  media_tag_id_map[old_id] = tag.id
end
puts "Created/found #{MediaTag.count} media tags"

# ============================================
# Collection Categories
# ============================================
collection_categories_data = [{:id=>1, :name=>"Historische Ansichtskarten", :slug=>"historische-ansichtskarten", :position=>0}, {:id=>2, :name=>"Historische Sterbebilder", :slug=>"historische-sterbebilder", :position=>1}, {:id=>3, :name=>"Historische Fotos", :slug=>"historische-fotos", :position=>2}, {:id=>4, :name=>"Erinnerungen", :slug=>"erinnerungen", :position=>4}, {:id=>5, :name=>"Markt Wartenberg Ort der Künste", :slug=>"markt-wartenberg-ort-der-kunste", :position=>5}]

collection_category_id_map = {}
collection_categories_data.each do |data|
  old_id = data.delete(:id)
  category = CollectionCategory.find_or_create_by!(name: data[:name]) do |c|
    c.slug = data[:slug]
    c.position = data[:position]
  end
  collection_category_id_map[old_id] = category.id
end
puts "Created/found #{CollectionCategory.count} collection categories"

# ============================================
# Artists
# ============================================
artists_data = [{:id=>2, :name=>"Carl Hans Schrader-Velgen", :slug=>"carl-hans-schrader-velgen", :birth_date=>"1876-03-08", :death_date=>"1945-01-21", :birth_place=>"Hannover", :death_place=>"Wartenber", :status=>"published", :published_at=>nil, :created_by_id=>1, :profile_media_item_id=>3, :biography=>"Die 1892 von jungen Münchner Künstlern gegründete „Sezession“ zog den gebürtigen Niedersachsen Schrader-Velgen bald in die neu aufleuchtende Kunststadt München. Die frische Luft der Freilichtmalerei, die Idee muffige Ateliers zu verlassen und die momentanen Lichtstimmungen unter freiem Himmel einzufangen hatte auch manche Akademieprofessoren erfasst und so schrieb Schrader-Velgen sich in deren Malklassen ein. Auf ständiger Suche nach malerischen Landschaften und bunten Motiven fand der Künstler zunächst die oberbayerischen Seen und dann als fast 50-Jähriger auch Wartenberg mit seinem unberührten Lauf der Strogen, den Hügelketten, weiten Feldern, bunten Blumenwiesen und urigen Bauernhäusern. In vielen Wartenberger Wohnhäusern finden sich farbenfrohe Gemälde Schrader-Velgens. Auch im Rathaus Wartenberg hängen in den Büros Gemälde von ihm.", :cv=>"• 08.03.1876   geboren in Hannover\n• Todo"}]
artist_files = {}

artist_id_map = {}
artists_data.each do |data|
  old_id = data.delete(:id)
  artist = Artist.find_or_initialize_by(slug: data[:slug])
  artist.assign_attributes(
    name: data[:name],
    birth_date: data[:birth_date].present? ? Date.parse(data[:birth_date]) : nil,
    death_date: data[:death_date].present? ? Date.parse(data[:death_date]) : nil,
    birth_place: data[:birth_place],
    death_place: data[:death_place],
    status: data[:status],
    published_at: data[:published_at].present? ? Time.parse(data[:published_at]) : nil,
    created_by_id: user_id_map[data[:created_by_id]] || User.first.id
  )
  artist.biography = data[:biography] if data[:biography].present?
  artist.cv = data[:cv] if data[:cv].present?
  artist.save!

  if artist_files[old_id] && !artist.profile_image.attached?
    attach_file(artist, :profile_image, artist_files[old_id])
  end

  artist_id_map[old_id] = artist.id
  print "."
end
puts "\nCreated/found #{Artist.count} artists"

# ============================================
# Media Items
# ============================================
media_items_data = [{:id=>1, :title=>"800 Jahrfeier", :description=>"Festumzug am 14.08.1955 anlässlich des 800-jährigen Jubiläums des Gefechtes an der Veroneser Klause", :media_type=>"image", :year=>1955, :source=>"", :copyright=>"", :license=>"", :status=>"published", :published_at=>"2026-01-21T09:33:47Z", :submitted_at=>"2026-01-21T09:32:31Z", :reviewed_at=>"2026-01-21T09:33:47Z", :uploaded_by_id=>1, :reviewed_by_id=>1, :artist_id=>nil, :technique_id=>nil}, {:id=>3, :title=>"Schrader-Velgen", :description=>"", :media_type=>"image", :year=>nil, :source=>"", :copyright=>"", :license=>"", :status=>"published", :published_at=>"2026-01-21T10:56:00Z", :submitted_at=>"2026-01-21T10:55:59Z", :reviewed_at=>"2026-01-21T10:56:00Z", :uploaded_by_id=>1, :reviewed_by_id=>1, :artist_id=>nil, :technique_id=>21}, {:id=>2, :title=>"Landschaft an der Strogen bei Schneeschmelze", :description=>"Landschaft an der Strogen bei Schneeschmelze", :media_type=>"image", :year=>nil, :source=>"", :copyright=>"", :license=>"", :status=>"published", :published_at=>"2026-01-21T10:38:05Z", :submitted_at=>"2026-01-21T10:38:04Z", :reviewed_at=>"2026-01-21T10:38:05Z", :uploaded_by_id=>1, :reviewed_by_id=>1, :artist_id=>2, :technique_id=>3}, {:id=>4, :title=>"Hahn", :description=>"", :media_type=>"image", :year=>nil, :source=>"", :copyright=>"", :license=>"", :status=>"published", :published_at=>"2026-01-21T11:42:49Z", :submitted_at=>"2026-01-21T11:42:48Z", :reviewed_at=>"2026-01-21T11:42:49Z", :uploaded_by_id=>1, :reviewed_by_id=>1, :artist_id=>nil, :technique_id=>21}, {:id=>5, :title=>"Moosburg und bad Wartenberg", :description=>"some text", :media_type=>"image", :year=>nil, :source=>"", :copyright=>"", :license=>"", :status=>"published", :published_at=>"2026-01-21T13:57:55Z", :submitted_at=>"2026-01-21T13:57:54Z", :reviewed_at=>"2026-01-21T13:57:55Z", :uploaded_by_id=>1, :reviewed_by_id=>1, :artist_id=>nil, :technique_id=>nil}, {:id=>6, :title=>"Wartenberg und Umgebung", :description=>"", :media_type=>"image", :year=>nil, :source=>"", :copyright=>"", :license=>"", :status=>"published", :published_at=>"2026-01-21T13:59:01Z", :submitted_at=>"2026-01-21T13:59:00Z", :reviewed_at=>"2026-01-21T13:59:01Z", :uploaded_by_id=>1, :reviewed_by_id=>1, :artist_id=>nil, :technique_id=>21}]
media_item_files = {1=>"media_items/1_Foto_415-800_Jahrfeier.jpg", 2=>"media_items/2_00001_Carl_Hans_Schrader_Velgen.jpg", 3=>"media_items/3_Carl-Hans Schrader-Velgen.jpg", 4=>"media_items/4_haan-10041654_1280.jpg", 5=>"media_items/5_00003-SWH_PK_054-1920_Moosburg-Bad_Wartenberg_aus_der_Vogelschau.jpeg", 6=>"media_items/6_00001-SWH_PK_033-1913_Wartenberg_und_Umgebung_a_d_Vogelschau.jpeg"}
media_taggings_data = [{:media_item_id=>1, :media_tag_id=>1}, {:media_item_id=>1, :media_tag_id=>2}, {:media_item_id=>4, :media_tag_id=>3}, {:media_item_id=>4, :media_tag_id=>4}, {:media_item_id=>6, :media_tag_id=>5}]

media_item_id_map = {}
media_items_data.each do |data|
  old_id = data.delete(:id)

  # Skip if no file available
  unless media_item_files[old_id]
    puts "\nSkipping media item #{old_id} - no file"
    next
  end

  media_item = MediaItem.find_or_initialize_by(title: data[:title], media_type: data[:media_type])

  if media_item.new_record?
    media_item.assign_attributes(
      description: data[:description],
      year: data[:year],
      source: data[:source],
      copyright: data[:copyright],
      license: data[:license],
      status: data[:status],
      published_at: data[:published_at].present? ? Time.parse(data[:published_at]) : nil,
      submitted_at: data[:submitted_at].present? ? Time.parse(data[:submitted_at]) : nil,
      reviewed_at: data[:reviewed_at].present? ? Time.parse(data[:reviewed_at]) : nil,
      uploaded_by_id: user_id_map[data[:uploaded_by_id]] || User.first.id,
      reviewed_by_id: data[:reviewed_by_id] ? user_id_map[data[:reviewed_by_id]] : nil,
      artist_id: data[:artist_id] ? artist_id_map[data[:artist_id]] : nil,
      technique_id: data[:technique_id] ? technique_id_map[data[:technique_id]] : nil
    )

    if media_item_files[old_id]
      attach_file(media_item, :file, media_item_files[old_id])
    end

    media_item.save!
  end

  media_item_id_map[old_id] = media_item.id
  print "."
end
puts "\nCreated/found #{MediaItem.count} media items"

# Media Taggings
media_taggings_data.each do |data|
  media_item_id = media_item_id_map[data[:media_item_id]]
  media_tag_id = media_tag_id_map[data[:media_tag_id]]
  next unless media_item_id && media_tag_id

  MediaTagging.find_or_create_by!(
    media_item_id: media_item_id,
    media_tag_id: media_tag_id
  )
end
puts "Created media taggings"

# ============================================
# Articles
# ============================================
articles_data = [{:id=>1, :title=>"Füchse in Wartenberg", :slug=>"hahn", :status=>"published", :published_at=>nil, :author_id=>1, :cover_media_item_id=>nil, :content=>"Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.  \n\nDuis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.  \n\nUt wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.  \n\nNam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.  \n\nDuis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis.   \n\nAt vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, At accusam aliquyam diam diam dolore dolores duo eirmod eos erat, et nonumy sed tempor et et invidunt justo labore Stet clita ea et gubergren, kasd magna no rebum. sanctus sea sed takimata ut vero voluptua. est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat.  \n\nConsetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus.  \n\nLorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.  \n\nDuis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.  \n\nUt wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.  \n\nNam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.  \n\nDuis autem vel eum iriure dolor in"}, {:id=>2, :title=>"Hähne in wartenberg ", :slug=>"hahne-in-wartenberg", :status=>"published", :published_at=>nil, :author_id=>1, :cover_media_item_id=>4, :content=>"Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.  \n\nDuis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.  \n\n\n“Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.  ”\n\n\nNam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.  \nDuis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis.   \n\nAt vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, At accusam aliquyam diam diam dolore dolores duo eirmod eos erat, et nonumy sed tempor et et invidunt justo labore Stet clita ea et gubergren, kasd magna no rebum. sanctus sea sed takimata ut vero voluptua. est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat.  \n\nConsetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus.  \n\nLorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.  \n\nDuis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.  \n\nUt wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.  \n\nNam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.  \n\nDuis autem vel eum iriure dolor in"}]
article_files = {1=>"articles/1_dog-9830812_1920.jpg", 2=>"articles/2_haan-10041654_1280.jpg"}

article_id_map = {}
articles_data.each do |data|
  old_id = data.delete(:id)
  article = Article.find_or_initialize_by(slug: data[:slug])
  article.assign_attributes(
    title: data[:title],
    status: data[:status],
    published_at: data[:published_at].present? ? Time.parse(data[:published_at]) : nil,
    author_id: user_id_map[data[:author_id]] || User.first.id,
    cover_media_item_id: data[:cover_media_item_id] ? media_item_id_map[data[:cover_media_item_id]] : nil
  )
  article.content = data[:content] if data[:content].present?
  article.save!

  if article_files[old_id] && !article.cover_image.attached?
    attach_file(article, :cover_image, article_files[old_id])
  end

  article_id_map[old_id] = article.id
  print "."
end
puts "\nCreated/found #{Article.count} articles"

# ============================================
# Collections
# ============================================
collections_data = [{:id=>1, :name=>"Luftbilder ", :slug=>"luftbilder", :position=>0, :status=>"published", :published_at=>nil, :collection_category_id=>1, :cover_media_item_id=>6, :created_by_id=>1, :description=>"some cool stuff here "}]

collection_id_map = {}
collections_data.each do |data|
  old_id = data.delete(:id)
  collection = Collection.find_or_initialize_by(slug: data[:slug])
  collection.assign_attributes(
    name: data[:name],
    position: data[:position],
    status: data[:status],
    published_at: data[:published_at].present? ? Time.parse(data[:published_at]) : nil,
    collection_category_id: collection_category_id_map[data[:collection_category_id]],
    cover_media_item_id: data[:cover_media_item_id] ? media_item_id_map[data[:cover_media_item_id]] : nil,
    created_by_id: user_id_map[data[:created_by_id]] || User.first.id
  )
  collection.description = data[:description] if data[:description].present?
  collection.save!

  collection_id_map[old_id] = collection.id
  print "."
end
puts "\nCreated/found #{Collection.count} collections"

# ============================================
# Collection Items
# ============================================
collection_items_data = [{:collection_id=>1, :media_item_id=>5, :position=>0}, {:collection_id=>1, :media_item_id=>6, :position=>1}]

collection_items_data.each do |data|
  collection_id = collection_id_map[data[:collection_id]]
  media_item_id = media_item_id_map[data[:media_item_id]]
  next unless collection_id && media_item_id

  CollectionItem.find_or_create_by!(
    collection_id: collection_id,
    media_item_id: media_item_id
  ) do |item|
    item.position = data[:position]
  end
end
puts "Created collection items"

# Update artist profile_media_item references
Artist.find_by(slug: "carl-hans-schrader-velgen")&.update_column(:profile_media_item_id, media_item_id_map[3])

puts "\n✅ Generated seeds loaded successfully!"
