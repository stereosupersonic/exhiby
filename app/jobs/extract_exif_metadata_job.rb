class ExtractExifMetadataJob < ApplicationJob
  queue_as :default

  def perform(media_item_id)
    media_item = MediaItem.find_by(id: media_item_id)
    return unless media_item&.file&.attached?
    return unless media_item.image?

    media_item.file.blob.open do |tempfile|
      result = ExifMetadataExtractor.call(tempfile.path)

      attributes = { exif_metadata: result[:all_tags] }
      attributes.merge!(suggested_attributes(result[:suggested_values], media_item))

      media_item.update!(attributes)

      apply_tags(media_item, result[:all_tags])
    end
  rescue StandardError => e
    Rails.logger.error("Failed to extract EXIF for MediaItem #{media_item_id}: #{e.message}")
  end

  private

  def suggested_attributes(suggested_values, _media_item)
    {
      title: suggested_values[:title].presence,
      description: suggested_values[:description].presence,
      year: suggested_values[:year].presence,
      copyright: suggested_values[:copyright].presence,
      source: suggested_values[:source].presence
    }.compact
  end

  def apply_tags(media_item, exif_tags)
    keywords = extract_keywords(exif_tags)

    # Clear existing tags and apply new ones from EXIF
    media_item.media_tags = []
    return if keywords.blank?

    media_item.tag_list = keywords.join(", ")
    media_item.save!
  end

  def extract_keywords(exif_tags)
    # Try different EXIF fields that might contain keywords/tags
    keywords = exif_tags["Keywords"] || exif_tags["Subject"] || exif_tags["XPKeywords"]

    case keywords
    when String
      keywords.split(/[,;]/).map(&:strip).reject(&:blank?)
    when Array
      keywords.map(&:to_s).map(&:strip).reject(&:blank?)
    else
      []
    end
  end
end
