# == Schema Information
#
# Table name: media_tags
#
#  id                :bigint           not null, primary key
#  media_items_count :integer          default(0)
#  name              :string           not null
#  slug              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_media_tags_on_name  (name) UNIQUE
#  index_media_tags_on_slug  (slug) UNIQUE
#
class MediaTag < ApplicationRecord
  has_many :media_taggings, dependent: :destroy
  has_many :media_items, through: :media_taggings

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  scope :popular, -> { order(media_items_count: :desc) }
  scope :alphabetical, -> { order(:name) }

  def self.find_or_create_by_name(name)
    find_by("LOWER(name) = ?", name.downcase) || create(name: name)
  end

  private

  def generate_slug
    return if name.blank?

    self.slug = name.parameterize
  end
end
