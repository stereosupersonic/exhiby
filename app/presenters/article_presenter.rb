class ArticlePresenter < ApplicationPresenter
  def formatted_published_at
    return I18n.t("common.not_published") unless o.published_at

    I18n.l(o.published_at, format: :long)
  end

  def formatted_published_at_short
    return I18n.t("common.not_published") unless o.published_at

    I18n.l(o.published_at, format: :short)
  end

  def status_badge_class
    o.published? ? "bg-success" : "bg-secondary"
  end

  def status_label
    o.status_name
  end

  def author_name
    o.author.email_address
  end

  def excerpt(length: 150)
    o.content.to_plain_text.truncate(length)
  end
end
