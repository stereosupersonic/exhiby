# == Schema Information
#
# Table name: artists
#
#  id                    :bigint           not null, primary key
#  birth_date            :date
#  birth_place           :string
#  death_date            :date
#  death_place           :string
#  name                  :string           not null
#  published_at          :datetime
#  slug                  :string           not null
#  status                :string           default("draft"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  created_by_id         :bigint           not null
#  profile_media_item_id :bigint
#
# Indexes
#
#  index_artists_on_created_by_id          (created_by_id)
#  index_artists_on_profile_media_item_id  (profile_media_item_id)
#  index_artists_on_published_at           (published_at)
#  index_artists_on_slug                   (slug) UNIQUE
#  index_artists_on_status                 (status)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (profile_media_item_id => media_items.id)
#
class Artist < ApplicationRecord
  STATUSES = %w[draft published].freeze

  belongs_to :created_by, class_name: "User"
  belongs_to :profile_media_item, class_name: "MediaItem", optional: true
  has_many :media_items, dependent: :restrict_with_error

  has_one_attached :profile_image
  has_rich_text :biography
  has_rich_text :cv

  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :generate_slug

  scope :draft, -> { where(status: "draft") }
  scope :published, -> { where(status: "published") }
  scope :recent, -> { order(created_at: :desc) }
  scope :alphabetical, -> { order(:name) }
  scope :search, ->(query) {
    if query.present?
      joins("LEFT JOIN action_text_rich_texts ON action_text_rich_texts.record_id = artists.id AND action_text_rich_texts.record_type = 'Artist' AND action_text_rich_texts.name = 'biography'")
        .where("artists.name ILIKE :q OR action_text_rich_texts.body ILIKE :q", q: "%#{query}%")
        .distinct
    end
  }
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

  def life_dates
    return nil if birth_date.blank? && death_date.blank?

    birth_year = birth_date&.year
    death_year = death_date&.year

    if birth_year && death_year
      "#{birth_year} – #{death_year}"
    elsif birth_year
      "geb. #{birth_year}"
    elsif death_year
      "gest. #{death_year}"
    end
  end

  private

  def generate_slug
    return if name.blank?
    return if persisted? && !name_changed?
    return if new_record? && slug.present?

    base_slug = name.parameterize
    self.slug = base_slug

    counter = 1
    while Artist.where.not(id: id).exists?(slug: slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
