# == Schema Information
#
# Table name: articles
#
#  id                  :bigint           not null, primary key
#  published_at        :datetime
#  slug                :string           not null
#  status              :string           default("draft"), not null
#  title               :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  author_id           :bigint           not null
#  cover_media_item_id :bigint
#
# Indexes
#
#  index_articles_on_author_id            (author_id)
#  index_articles_on_cover_media_item_id  (cover_media_item_id)
#  index_articles_on_published_at         (published_at)
#  index_articles_on_slug                 (slug) UNIQUE
#  index_articles_on_status               (status)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (cover_media_item_id => media_items.id)
#
class Article < ApplicationRecord
  STATUSES = %w[draft published].freeze

  belongs_to :author, class_name: "User"
  belongs_to :cover_media_item, class_name: "MediaItem", optional: true
  has_rich_text :content
  has_one_attached :cover_image

  validates :title, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :generate_slug

  scope :published, -> { where(status: "published").where("published_at IS NULL OR published_at <= ?", Time.current) }
  scope :recent, ->(limit = 3) { published.order(Arel.sql("COALESCE(published_at, created_at) DESC")).limit(limit) }
  scope :by_publication_date, -> { order(published_at: :desc) }
  scope :search, ->(query) {
    if query.present?
      joins("LEFT JOIN action_text_rich_texts ON action_text_rich_texts.record_id = articles.id AND action_text_rich_texts.record_type = 'Article' AND action_text_rich_texts.name = 'content'")
        .where("articles.title ILIKE :q OR action_text_rich_texts.body ILIKE :q", q: "%#{query}%")
        .distinct
    end
  }

  def to_param
    slug
  end

  def published?
    status == "published" && (published_at.nil? || published_at <= Time.current)
  end

  def draft?
    status == "draft"
  end

  private

  def generate_slug
    return if title.blank?
    return if persisted? && !title_changed?
    return if new_record? && slug.present?

    base_slug = title.parameterize
    self.slug = base_slug

    counter = 1
    while Article.where.not(id: id).exists?(slug: slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
