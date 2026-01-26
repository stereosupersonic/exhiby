# == Schema Information
#
# Table name: collection_categories
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  position   :integer          default(0), not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_collection_categories_on_name      (name) UNIQUE
#  index_collection_categories_on_position  (position)
#  index_collection_categories_on_slug      (slug) UNIQUE
#
class CollectionCategory < ApplicationRecord
  has_many :collections, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true, length: { maximum: 255 }

  before_validation :generate_slug

  scope :ordered, -> { order(:position, :name) }
  scope :alphabetical, -> { order(:name) }

  def to_param
    slug
  end

  def collections_count
    collections.count
  end

  def published_collections_count
    collections.published.count
  end

  private

  def generate_slug
    return if name.blank?
    return if persisted? && !name_changed?
    return if new_record? && slug.present?

    base_slug = name.parameterize
    self.slug = base_slug

    counter = 1
    while CollectionCategory.where.not(id: id).exists?(slug: slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
