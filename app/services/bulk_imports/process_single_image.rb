module BulkImports
  class ProcessSingleImage < BaseService
    attr_reader :file_path, :filename, :csv_metadata, :bulk_import, :user

    def initialize(file_path:, filename:, csv_metadata:, bulk_import:, user:)
      @file_path = file_path
      @filename = filename
      @csv_metadata = csv_metadata || {}
      @bulk_import = bulk_import
      @user = user
    end

    def call
      validate_file!

      file = File.open(file_path)
      exif_data = extract_exif_metadata
      media_item = build_media_item(file, exif_data)
      attribute_sources = track_attribute_sources(media_item, exif_data)

      if media_item.save
        {
          success: true,
          media_item_id: media_item.id,
          filename: filename,
          attribute_sources: attribute_sources
        }
      else
        {
          success: false,
          filename: filename,
          errors: media_item.errors.full_messages
        }
      end
    rescue StandardError => e
      Rails.logger.error("Failed to process image #{filename}: #{e.message}")
      {
        success: false,
        filename: filename,
        errors: [ e.message ]
      }
    ensure
      file&.close
    end

    private

    def validate_file!
      raise ArgumentError, "File does not exist: #{file_path}" unless File.exist?(file_path)

      content_type = Marcel::MimeType.for(Pathname.new(file_path))
      unless content_type.start_with?("image/")
        raise ArgumentError, "Invalid file type: #{content_type}"
      end
    end

    def build_media_item(file, exif_data)
      media_item = MediaItem.new(
        uploaded_by: user,
        bulk_import: bulk_import,
        media_type: "image",
        status: "draft"
      )

      media_item.file.attach(
        io: file,
        filename: filename,
        content_type: Marcel::MimeType.for(Pathname.new(file_path))
      )

      apply_attributes(media_item, exif_data)

      media_item
    end

    def extract_exif_metadata
      ExifMetadataExtractor.call(file_path)
    rescue StandardError => e
      Rails.logger.warn("EXIF extraction failed for #{filename}: #{e.message}")
      { suggested_values: {}, all_tags: {} }
    end

    def apply_attributes(media_item, exif_data)
      suggested = exif_data[:suggested_values] || {}

      media_item.title = determine_title(suggested)
      media_item.description = csv_metadata[:description].presence || suggested[:description]
      media_item.year = csv_metadata[:year] || suggested[:year]
      media_item.source = csv_metadata[:source].presence || suggested[:source]
      media_item.copyright = csv_metadata[:copyright].presence || suggested[:copyright]
      media_item.exif_metadata = exif_data[:all_tags]

      apply_artist(media_item)
      apply_technique(media_item)
      apply_tags(media_item, suggested)
    end

    def determine_title(suggested)
      csv_metadata[:title].presence ||
        suggested[:title].presence ||
        humanize_filename
    end

    def humanize_filename
      File.basename(filename, ".*")
        .gsub(/[-_]/, " ")
        .gsub(/\s+/, " ")
        .strip
        .titleize
    end

    def apply_artist(media_item)
      return if csv_metadata[:artist_name].blank?

      artist = Artist.find_by("LOWER(name) = ?", csv_metadata[:artist_name].downcase)
      media_item.artist = artist if artist
    end

    def apply_technique(media_item)
      return if csv_metadata[:technique_name].blank?

      technique = Technique.find_by("LOWER(name) = ?", csv_metadata[:technique_name].downcase)
      media_item.technique = technique if technique
    end

    def apply_tags(media_item, suggested)
      tags = csv_metadata[:tags].presence || extract_tags_from_exif(suggested)
      return if tags.blank?

      media_item.media_tags = tags.map { |name| MediaTag.find_or_create_by_name(name) }
    end

    def extract_tags_from_exif(suggested)
      keywords = suggested[:keywords]
      return [] if keywords.blank?

      case keywords
      when Array
        keywords
      when String
        keywords.split(/[,;]/).map(&:strip).reject(&:blank?)
      else
        []
      end
    end

    def track_attribute_sources(media_item, exif_data)
      sources = {}
      suggested = exif_data[:suggested_values] || {}

      sources[:title] = attribute_source(:title, suggested)
      sources[:description] = attribute_source(:description, suggested) if media_item.description.present?
      sources[:year] = attribute_source(:year, suggested) if media_item.year.present?
      sources[:source] = attribute_source(:source, suggested) if media_item.source.present?
      sources[:copyright] = attribute_source(:copyright, suggested) if media_item.copyright.present?

      sources
    end

    def attribute_source(attribute, exif_suggested)
      if csv_metadata[attribute].present?
        "csv"
      elsif exif_suggested[attribute].present?
        "exif"
      else
        "filename"
      end
    end
  end
end
