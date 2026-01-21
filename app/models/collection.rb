# == Schema Information
#
# Table name: collections
#
#  id                     :bigint           not null, primary key
#  name                   :string           not null
#  position               :integer          default(0), not null
#  published_at           :datetime
#  slug                   :string           not null
#  status                 :string           default("draft"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  collection_category_id :bigint           not null
#  cover_media_item_id    :bigint
#  created_by_id          :bigint           not null
#
# Indexes
#
#  index_collections_on_collection_category_id               (collection_category_id)
#  index_collections_on_collection_category_id_and_position  (collection_category_id,position)
#  index_collections_on_cover_media_item_id                  (cover_media_item_id)
#  index_collections_on_created_by_id                        (created_by_id)
#  index_collections_on_published_at                         (published_at)
#  index_collections_on_slug                                 (slug) UNIQUE
#  index_collections_on_status                               (status)
#
# Foreign Keys
#
#  fk_rails_...  (collection_category_id => collection_categories.id)
#  fk_rails_...  (cover_media_item_id => media_items.id)
#  fk_rails_...  (created_by_id => users.id)
#
class Collection < ApplicationRecord
  STATUSES = %w[draft published].freeze

  belongs_to :collection_category
  belongs_to :created_by, class_name: "User"
  belongs_to :cover_media_item, class_name: "MediaItem", optional: true

  has_many :collection_items, dependent: :destroy
  has_many :media_items, through: :collection_items

  has_rich_text :description

  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :generate_slug

  scope :draft, -> { where(status: "draft") }
  scope :published, -> { where(status: "published") }
  scope :ordered, -> { order(:position, :name) }
  scope :alphabetical, -> { order(:name) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(category_id) { where(collection_category_id: category_id) if category_id.present? }
  scope :search, ->(query) { where("name ILIKE ?", "%#{query}%") if query.present? }
  scope :by_status, ->(status) { where(status: status) if status.present? }

  def to_param
    slug
  end

  def draft?
    status == "draft"
  end

  def published?
    status == "published"
  end

  def publish!
    update!(status: "published", published_at: Time.current)
  end

  def unpublish!
    update!(status: "draft", published_at: nil)
  end

  def media_items_count
    collection_items.count
  end

  def ordered_media_items
    media_items.order("collection_items.position ASC")
  end

  private

  def generate_slug
    return if name.blank?
    return if persisted? && !name_changed?
    return if new_record? && slug.present?

    base_slug = name.parameterize
    self.slug = base_slug

    counter = 1
    while Collection.where.not(id: id).exists?(slug: slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
