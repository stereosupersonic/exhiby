# == Schema Information
#
# Table name: pictures_of_the_day
#
#  id            :bigint           not null, primary key
#  caption       :string
#  description   :text
#  display_date  :date             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint           not null
#  media_item_id :bigint           not null
#
# Indexes
#
#  index_pictures_of_the_day_on_created_by_id  (created_by_id)
#  index_pictures_of_the_day_on_display_date   (display_date) UNIQUE
#  index_pictures_of_the_day_on_media_item_id  (media_item_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (media_item_id => media_items.id) ON DELETE => restrict
#
class PictureOfTheDay < ApplicationRecord
  self.table_name = "pictures_of_the_day"

  belongs_to :media_item
  belongs_to :created_by, class_name: "User"

  validates :display_date, presence: true, uniqueness: true
  validate :media_item_must_be_published_image

  scope :past, -> { where("display_date <= ?", Date.current).order(display_date: :desc) }
  scope :upcoming, -> { where("display_date > ?", Date.current).order(display_date: :asc) }
  scope :recent, ->(limit = 10) { past.limit(limit) }

  def self.for_date(date)
    find_by(display_date: date)
  end

  def self.today
    find_by(display_date: Date.current)
  end

  def self.current_or_most_recent
    today || past.first
  end

  def display_title
    caption.presence || media_item.title
  end

  def display_description
    description.presence || media_item.description
  end

  def past?
    display_date < Date.current
  end

  def today?
    display_date == Date.current
  end

  def upcoming?
    display_date > Date.current
  end

  private

  def media_item_must_be_published_image
    return if media_item.blank?

    unless media_item.image?
      errors.add(:media_item, :must_be_image)
    end

    unless media_item.published?
      errors.add(:media_item, :must_be_published)
    end
  end
end
