# == Schema Information
#
# Table name: techniques
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
#  index_techniques_on_name      (name) UNIQUE
#  index_techniques_on_position  (position)
#  index_techniques_on_slug      (slug) UNIQUE
#
class Technique < ApplicationRecord
  has_many :media_items, dependent: :nullify

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true, length: { maximum: 255 }

  before_validation :generate_slug

  scope :ordered, -> { order(:position, :name) }
  scope :search, ->(query) { where("name ILIKE ?", "%#{query}%") if query.present? }

  def to_param
    slug
  end

  private

  def generate_slug
    return if name.blank?
    return if persisted? && !name_changed?
    return if new_record? && slug.present?

    base_slug = name.parameterize
    self.slug = base_slug

    counter = 1
    while Technique.where.not(id: id).exists?(slug: slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
