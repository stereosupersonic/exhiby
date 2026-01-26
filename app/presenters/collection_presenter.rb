class CollectionPresenter < ApplicationPresenter
  STATUS_BADGE_CLASSES = {
    "published" => "bg-success",
    "draft" => "bg-secondary"
  }.freeze

  def status_badge_class
    STATUS_BADGE_CLASSES.fetch(o.status, "bg-secondary")
  end

  def status_name
    I18n.t("collection_statuses.#{o.status}")
  end

  def formatted_published_at
    return I18n.t("common.not_published") unless o.published_at

    I18n.l(o.published_at, format: :long)
  end

  def formatted_published_at_short
    return I18n.t("common.not_published") unless o.published_at

    I18n.l(o.published_at, format: :short)
  end

  def creator_email
    o.created_by.email_address
  end

  def media_items_count
    o.media_items_count
  end

  def category_name
    o.collection_category&.name
  end
end
