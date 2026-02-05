class MediaItemPresenter < ApplicationPresenter
  STATUS_BADGE_CLASSES = {
    "draft" => "bg-secondary",
    "pending_review" => "bg-warning text-dark",
    "published" => "bg-success"
  }.freeze

  MEDIA_TYPE_BADGE_CLASSES = {
    "image" => "bg-primary",
    "video" => "bg-info",
    "pdf" => "bg-danger"
  }.freeze

  def status_badge_class
    STATUS_BADGE_CLASSES.fetch(o.status, "bg-secondary")
  end

  def status_name
    I18n.t("media_item_statuses.#{o.status}")
  end

  def media_type_badge_class
    MEDIA_TYPE_BADGE_CLASSES.fetch(o.media_type, "bg-secondary")
  end

  def media_type_name
    I18n.t("media_item_types.#{o.media_type}")
  end

  def technique_name
    o.technique&.name
  end

  def uploader_name
    o.uploaded_by.email_address
  end

  def formatted_published_at
    return I18n.t("common.not_published") unless o.published_at

    I18n.l(o.published_at, format: :long)
  end

  def formatted_submitted_at
    return nil unless o.submitted_at

    I18n.l(o.submitted_at, format: :long)
  end

  def file_info
    return nil unless o.file.attached?

    filename = o.file.filename.to_s
    size = number_to_human_size(o.file.byte_size)
    "#{filename} (#{size})"
  end

  def file_size
    return nil unless o.file.attached?

    number_to_human_size(o.file.byte_size)
  end

  def thumbnail_url(size: [ 300, 200 ])
    return nil unless o.file.attached? && o.image?

    Rails.application.routes.url_helpers.rails_blob_path(
      o.file.variant(resize_to_fill: size),
      only_path: true
    )
  end

  def has_exif_data?
    o.has_exif_data?
  end

  def exif_grouped_tags
    return {} unless has_exif_data?

    ExifMetadataExtractor::DISPLAY_TAGS.transform_values do |tags|
      tags.each_with_object({}) do |tag, hash|
        value = o.exif_metadata[tag]
        hash[tag] = value if value.present?
      end.presence
    end.compact
  end

  def exif_all_tags
    o.exif_metadata || {}
  end

  def phash_short
    return nil unless o.has_phash?

    o.phash[0, 8]
  end
end
