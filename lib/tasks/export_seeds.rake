namespace :db do
  namespace :seed do
    desc "Export current database data and images as seeds"
    task export: :environment do
      require "fileutils"

      seed_dir = Rails.root.join("db/seeds")
      images_dir = seed_dir.join("images")

      # Create directories
      FileUtils.mkdir_p(images_dir)
      FileUtils.mkdir_p(images_dir.join("media_items"))
      FileUtils.mkdir_p(images_dir.join("artists"))
      FileUtils.mkdir_p(images_dir.join("articles"))

      puts "Exporting seeds to #{seed_dir}..."

      # Export images and collect file mappings
      media_item_files = export_media_item_files(images_dir)
      artist_files = export_artist_files(images_dir)
      article_files = export_article_files(images_dir)

      # Generate seed file
      seed_content = generate_seed_file(media_item_files, artist_files, article_files)

      File.write(seed_dir.join("generated_seeds.rb"), seed_content)
      puts "Generated #{seed_dir.join('generated_seeds.rb')}"

      puts "\nExport complete!"
      puts "To use these seeds, add the following to db/seeds.rb:"
      puts "  load Rails.root.join('db/seeds/generated_seeds.rb')"
    end

    def export_media_item_files(images_dir)
      files = {}
      MediaItem.find_each do |item|
        next unless item.file.attached?

        begin
          filename = "#{item.id}_#{item.file.filename}"
          filepath = images_dir.join("media_items", filename)
          File.open(filepath, "wb") do |file|
            file.write(item.file.download)
          end
          files[item.id] = "media_items/#{filename}"
          print "."
        rescue StandardError => e
          puts "\nError exporting media item #{item.id}: #{e.message}"
        end
      end
      puts "\nExported #{files.size} media item files"
      files
    end

    def export_artist_files(images_dir)
      files = {}
      Artist.find_each do |artist|
        next unless artist.profile_image.attached?

        begin
          filename = "#{artist.id}_#{artist.profile_image.filename}"
          filepath = images_dir.join("artists", filename)
          File.open(filepath, "wb") do |file|
            file.write(artist.profile_image.download)
          end
          files[artist.id] = "artists/#{filename}"
          print "."
        rescue StandardError => e
          puts "\nError exporting artist #{artist.id}: #{e.message}"
        end
      end
      puts "\nExported #{files.size} artist profile images"
      files
    end

    def export_article_files(images_dir)
      files = {}
      Article.find_each do |article|
        next unless article.cover_image.attached?

        begin
          filename = "#{article.id}_#{article.cover_image.filename}"
          filepath = images_dir.join("articles", filename)
          File.open(filepath, "wb") do |file|
            file.write(article.cover_image.download)
          end
          files[article.id] = "articles/#{filename}"
          print "."
        rescue StandardError => e
          puts "\nError exporting article #{article.id}: #{e.message}"
        end
      end
      puts "\nExported #{files.size} article cover images"
      files
    end

    def generate_seed_file(media_item_files, artist_files, article_files)
      content = <<~RUBY
        # Generated seeds from database export
        # Generated at: #{Time.current}
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
        users_data = #{format_users_data}

        user_id_map = {}
        users_data.each do |data|
          old_id = data.delete(:id)
          user = User.find_or_create_by!(email_address: data[:email_address]) do |u|
            u.password = data[:password] || "password"
            u.role = data[:role]
          end
          user_id_map[old_id] = user.id
        end
        puts "Created/found \#{User.count} users"

        # ============================================
        # Techniques
        # ============================================
        techniques_data = #{format_techniques_data}

        technique_id_map = {}
        techniques_data.each do |data|
          old_id = data.delete(:id)
          technique = Technique.find_or_create_by!(name: data[:name]) do |t|
            t.position = data[:position]
          end
          technique_id_map[old_id] = technique.id
        end
        puts "Created/found \#{Technique.count} techniques"

        # ============================================
        # Media Tags
        # ============================================
        media_tags_data = #{format_media_tags_data}

        media_tag_id_map = {}
        media_tags_data.each do |data|
          old_id = data.delete(:id)
          tag = MediaTag.find_or_create_by!(name: data[:name])
          media_tag_id_map[old_id] = tag.id
        end
        puts "Created/found \#{MediaTag.count} media tags"

        # ============================================
        # Collection Categories
        # ============================================
        collection_categories_data = #{format_collection_categories_data}

        collection_category_id_map = {}
        collection_categories_data.each do |data|
          old_id = data.delete(:id)
          category = CollectionCategory.find_or_create_by!(name: data[:name]) do |c|
            c.slug = data[:slug]
            c.position = data[:position]
          end
          collection_category_id_map[old_id] = category.id
        end
        puts "Created/found \#{CollectionCategory.count} collection categories"

        # ============================================
        # Artists
        # ============================================
        artists_data = #{format_artists_data}
        artist_files = #{artist_files.inspect}

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
        puts "\\nCreated/found \#{Artist.count} artists"

        # ============================================
        # Media Items
        # ============================================
        media_items_data = #{format_media_items_data}
        media_item_files = #{media_item_files.inspect}
        media_taggings_data = #{format_media_taggings_data}

        media_item_id_map = {}
        media_items_data.each do |data|
          old_id = data.delete(:id)

          # Skip if no file available
          unless media_item_files[old_id]
            puts "\\nSkipping media item \#{old_id} - no file"
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
        puts "\\nCreated/found \#{MediaItem.count} media items"

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
        articles_data = #{format_articles_data}
        article_files = #{article_files.inspect}

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
        puts "\\nCreated/found \#{Article.count} articles"

        # ============================================
        # Collections
        # ============================================
        collections_data = #{format_collections_data}

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
        puts "\\nCreated/found \#{Collection.count} collections"

        # ============================================
        # Collection Items
        # ============================================
        collection_items_data = #{format_collection_items_data}

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
        #{format_artist_profile_updates}

        puts "\\n✅ Generated seeds loaded successfully!"
      RUBY

      content
    end

    def format_users_data
      User.all.map do |u|
        {
          id: u.id,
          email_address: u.email_address,
          role: u.role,
          password: "password"
        }
      end.inspect
    end

    def format_techniques_data
      Technique.all.order(:position).map do |t|
        {
          id: t.id,
          name: t.name,
          position: t.position
        }
      end.inspect
    end

    def format_media_tags_data
      MediaTag.all.map do |t|
        {
          id: t.id,
          name: t.name
        }
      end.inspect
    end

    def format_collection_categories_data
      CollectionCategory.all.order(:position).map do |c|
        {
          id: c.id,
          name: c.name,
          slug: c.slug,
          position: c.position
        }
      end.inspect
    end

    def format_artists_data
      Artist.all.map do |a|
        {
          id: a.id,
          name: a.name,
          slug: a.slug,
          birth_date: a.birth_date&.to_s,
          death_date: a.death_date&.to_s,
          birth_place: a.birth_place,
          death_place: a.death_place,
          status: a.status,
          published_at: a.published_at&.iso8601,
          created_by_id: a.created_by_id,
          profile_media_item_id: a.profile_media_item_id,
          biography: a.biography&.to_plain_text,
          cv: a.cv&.to_plain_text
        }
      end.inspect
    end

    def format_media_items_data
      MediaItem.all.map do |m|
        {
          id: m.id,
          title: m.title,
          description: m.description,
          media_type: m.media_type,
          year: m.year,
          source: m.source,
          copyright: m.copyright,
          license: m.license,
          status: m.status,
          published_at: m.published_at&.iso8601,
          submitted_at: m.submitted_at&.iso8601,
          reviewed_at: m.reviewed_at&.iso8601,
          uploaded_by_id: m.uploaded_by_id,
          reviewed_by_id: m.reviewed_by_id,
          artist_id: m.artist_id,
          technique_id: m.technique_id
        }
      end.inspect
    end

    def format_media_taggings_data
      MediaTagging.all.map do |t|
        {
          media_item_id: t.media_item_id,
          media_tag_id: t.media_tag_id
        }
      end.inspect
    end

    def format_articles_data
      Article.all.map do |a|
        {
          id: a.id,
          title: a.title,
          slug: a.slug,
          status: a.status,
          published_at: a.published_at&.iso8601,
          author_id: a.author_id,
          cover_media_item_id: a.cover_media_item_id,
          content: a.content&.to_plain_text
        }
      end.inspect
    end

    def format_collections_data
      Collection.all.map do |c|
        {
          id: c.id,
          name: c.name,
          slug: c.slug,
          position: c.position,
          status: c.status,
          published_at: c.published_at&.iso8601,
          collection_category_id: c.collection_category_id,
          cover_media_item_id: c.cover_media_item_id,
          created_by_id: c.created_by_id,
          description: c.description&.to_plain_text
        }
      end.inspect
    end

    def format_collection_items_data
      CollectionItem.all.map do |i|
        {
          collection_id: i.collection_id,
          media_item_id: i.media_item_id,
          position: i.position
        }
      end.inspect
    end

    def format_artist_profile_updates
      updates = Artist.where.not(profile_media_item_id: nil).map do |a|
        "Artist.find_by(slug: #{a.slug.inspect})&.update_column(:profile_media_item_id, media_item_id_map[#{a.profile_media_item_id}])"
      end
      updates.join("\n")
    end
  end
end
