class ArticlePresenter < ApplicationPresenter
  STATUS_BADGE_CLASSES = {
    "published" => "bg-success",
    "draft" => "bg-secondary"
  }.freeze

  def formatted_published_at
    return I18n.t("common.not_published") unless o.published_at

    I18n.l(o.published_at, format: :long)
  end

  def formatted_published_at_short
    return I18n.t("common.not_published") unless o.published_at

    I18n.l(o.published_at, format: :short)
  end

  def formatted_published_at_month_year
    return nil unless o.published_at

    I18n.l(o.published_at.to_date, format: :month_year)
  end

  def status_badge_class
    STATUS_BADGE_CLASSES.fetch(o.status, "bg-secondary")
  end

  def status_name
    I18n.t("article_statuses.#{o.status}")
  end

  def author_name
    o.author.email_address
  end

  def excerpt(length: 150)
    o.content.to_plain_text.truncate(length)
  end
end
