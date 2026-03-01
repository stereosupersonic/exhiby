module ApplicationHelper
  SITE_NAME = "OnlineMuseum Wartenberg".freeze

  # Page title with site name suffix
  # Usage: page_title("Kunstschaffende") => "Kunstschaffende | OnlineMuseum Wartenberg"
  def page_title(title = nil)
    if title.present?
      "#{title} | #{SITE_NAME}"
    else
      content_for(:title).presence || SITE_NAME
    end
  end

  # Meta description with fallback
  def meta_description
    content_for(:meta_description).presence || t("seo.default_description")
  end

  # Canonical URL
  def canonical_url
    content_for(:canonical_url).presence || request.original_url.split("?").first
  end

  # Truncate text for meta description (120-160 chars recommended)
  def truncate_for_meta(text, length: 155)
    return "" if text.blank?

    plain_text = strip_tags(text.to_s).squish
    truncate(plain_text, length: length, separator: " ", omission: "...")
  end
end
