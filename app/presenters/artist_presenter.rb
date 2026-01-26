class ArtistPresenter < ApplicationPresenter
  STATUS_BADGE_CLASSES = {
    "published" => "bg-success",
    "draft" => "bg-secondary"
  }.freeze

  def status_badge_class
    STATUS_BADGE_CLASSES.fetch(o.status, "bg-secondary")
  end

  def status_name
    I18n.t("artist_statuses.#{o.status}")
  end

  def formatted_published_at
    return I18n.t("common.not_published") unless o.published_at

    I18n.l(o.published_at, format: :long)
  end

  def formatted_published_at_short
    return I18n.t("common.not_published") unless o.published_at

    I18n.l(o.published_at, format: :short)
  end

  def formatted_birth_date
    return nil unless o.birth_date

    I18n.l(o.birth_date, format: :long)
  end

  def formatted_death_date
    return nil unless o.death_date

    I18n.l(o.death_date, format: :long)
  end

  def creator_email
    o.created_by.email_address
  end

  def display_life_dates
    o.life_dates
  end

  def birth_info
    return nil if o.birth_date.blank? && o.birth_place.blank?

    parts = []
    parts << "geb. #{o.birth_date.year}" if o.birth_date
    parts << "in #{o.birth_place}" if o.birth_place.present?
    parts.join(" ")
  end

  def death_info
    return nil if o.death_date.blank? && o.death_place.blank?

    parts = []
    parts << "gest. #{o.death_date.year}" if o.death_date
    parts << "in #{o.death_place}" if o.death_place.present?
    parts.join(" ")
  end

  def full_life_info
    [ birth_info, death_info ].compact.join(", ")
  end

  def media_items_count
    o.media_items.count
  end

  def published_media_items_count
    o.media_items.published.count
  end
end
