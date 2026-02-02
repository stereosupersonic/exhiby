class PictureOfTheDayPresenter < ApplicationPresenter
  STATUS_BADGE_CLASSES = {
    "past" => "bg-secondary",
    "today" => "bg-success",
    "upcoming" => "bg-info"
  }.freeze

  def display_title
    o.caption.presence || o.media_item.title
  end

  def display_description
    o.description.presence || o.media_item.description
  end

  def formatted_display_date
    I18n.l(o.display_date, format: :long)
  end

  def formatted_display_date_short
    I18n.l(o.display_date, format: :default)
  end

  def status_key
    if o.today?
      "today"
    elsif o.upcoming?
      "upcoming"
    else
      "past"
    end
  end

  def status_label
    I18n.t("picture_of_the_day_statuses.#{status_key}")
  end

  def status_badge_class
    STATUS_BADGE_CLASSES.fetch(status_key, "bg-secondary")
  end

  def hero_image_url(size: [ 1200, 600 ])
    return nil unless o.media_item.file.attached?

    o.media_item.file.variant(resize_to_fill: size)
  end

  def thumbnail_url(size: [ 400, 300 ])
    return nil unless o.media_item.file.attached?

    o.media_item.file.variant(resize_to_limit: size)
  end

  def created_by_name
    o.created_by.email_address
  end

  def media_item_title
    o.media_item.title
  end

  def artist_name
    o.media_item.artist&.name
  end

  def year
    o.media_item.year
  end

  def copyright
    o.media_item.copyright
  end
end
