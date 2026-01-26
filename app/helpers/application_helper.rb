module ApplicationHelper
  SITE_NAME = "OnlineMuseum Wartenberg".freeze
  DEFAULT_OG_IMAGE = "logo/Logo-Online-Museum-V10-250.png".freeze

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

  # Open Graph image URL
  def og_image_url
    if content_for?(:og_image)
      content_for(:og_image)
    else
      image_url(DEFAULT_OG_IMAGE)
    end
  end

  # Set page SEO metadata from controller/view
  # Usage: set_meta(title: "Page Title", description: "Page description")
  def set_meta(title: nil, description: nil, image: nil, canonical: nil)
    content_for(:title, title) if title.present?
    content_for(:meta_description, description) if description.present?
    content_for(:og_image, image) if image.present?
    content_for(:canonical_url, canonical) if canonical.present?
  end

  # Truncate text for meta description (120-160 chars recommended)
  def truncate_for_meta(text, length: 155)
    return "" if text.blank?

    plain_text = strip_tags(text.to_s).squish
    truncate(plain_text, length: length, separator: " ", omission: "...")
  end
end
