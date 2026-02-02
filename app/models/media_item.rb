# == Schema Information
#
# Table name: media_items
#
#  id               :bigint           not null, primary key
#  copyright        :string
#  description      :text
#  exif_metadata    :jsonb
#  license          :string
#  media_type       :string           not null
#  published_at     :datetime
#  reviewed_at      :datetime
#  source           :string
#  status           :string           default("draft"), not null
#  submitted_at     :datetime
#  technique_legacy :string
#  title            :string           not null
#  year             :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  artist_id        :bigint
#  reviewed_by_id   :bigint
#  technique_id     :bigint
#  uploaded_by_id   :bigint           not null
#
# Indexes
#
#  index_media_items_on_artist_id       (artist_id)
#  index_media_items_on_media_type      (media_type)
#  index_media_items_on_published_at    (published_at)
#  index_media_items_on_reviewed_by_id  (reviewed_by_id)
#  index_media_items_on_status          (status)
#  index_media_items_on_technique_id    (technique_id)
#  index_media_items_on_uploaded_by_id  (uploaded_by_id)
#  index_media_items_on_year            (year)
#
# Foreign Keys
#
#  fk_rails_...  (artist_id => artists.id) ON DELETE => restrict
#  fk_rails_...  (reviewed_by_id => users.id)
#  fk_rails_...  (technique_id => techniques.id)
#  fk_rails_...  (uploaded_by_id => users.id)
#
class MediaItem < ApplicationRecord
  STATUSES = %w[draft pending_review published].freeze
  MEDIA_TYPES = %w[image video pdf].freeze

  belongs_to :uploaded_by, class_name: "User"
  belongs_to :reviewed_by, class_name: "User", optional: true
  belongs_to :artist, optional: true
  belongs_to :technique, optional: true

  has_many :media_taggings, dependent: :destroy
  has_many :media_tags, through: :media_taggings
  has_many :pictures_of_the_day, dependent: :restrict_with_error

  has_one_attached :file

  before_save :sync_exif_metadata, if: :should_sync_exif?

  # Build a MediaItem with file and extract EXIF metadata before saving
  # @param file [ActionDispatch::Http::UploadedFile, File, Tempfile] the file to attach
  # @param attributes [Hash] additional attributes for the MediaItem
  # @return [MediaItem] unsaved MediaItem with EXIF data populated
  def self.build_with_file(file:, **attributes)
    media_item = new(attributes)
    media_item.attach_and_extract_exif(file)
    media_item
  end

  # Attach file and extract EXIF metadata
  # @param uploaded_file [ActionDispatch::Http::UploadedFile, File, Tempfile] the file to attach
  def attach_and_extract_exif(uploaded_file)
    return if uploaded_file.blank?

    file.attach(uploaded_file)
    extract_exif_from_uploaded_file(uploaded_file)
  end

  validates :title, presence: true, length: { maximum: 255 }
  validates :media_type, presence: true, inclusion: { in: MEDIA_TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :year, numericality: { only_integer: true, allow_nil: true,
                                   greater_than: 0, less_than_or_equal_to: ->(_) { Time.current.year } }
  validates :file, presence: true, on: :create

  scope :draft, -> { where(status: "draft") }
  scope :pending_review, -> { where(status: "pending_review") }
  scope :published, -> { where(status: "published") }
  scope :by_type, ->(type) { where(media_type: type) if type.present? }
  scope :by_year, ->(year) { where(year: year) if year.present? }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :recent, -> { order(created_at: :desc) }
  scope :search, ->(query) {
    if query.present?
      left_joins(:media_tags)
        .where("media_items.title ILIKE :q OR media_tags.name ILIKE :q", q: "%#{query}%")
        .distinct
    end
  }

  def draft?
    status == "draft"
  end

  def pending_review?
    status == "pending_review"
  end

  def published?
    status == "published"
  end

  def submit_for_review!
    return false unless draft?

    update!(status: "pending_review", submitted_at: Time.current)
  end

  def publish!(reviewer)
    return false unless pending_review?

    update!(
      status: "published",
      published_at: Time.current,
      reviewed_by: reviewer,
      reviewed_at: Time.current
    )
  end

  def reject!(reviewer)
    return false unless pending_review?

    update!(
      status: "draft",
      reviewed_by: reviewer,
      reviewed_at: Time.current,
      submitted_at: nil
    )
  end

  def unpublish!
    return false unless published?

    update!(
      status: "draft",
      published_at: nil,
      submitted_at: nil
    )
  end

  def image?
    media_type == "image"
  end

  def video?
    media_type == "video"
  end

  def pdf?
    media_type == "pdf"
  end

  def tag_list
    media_tags.pluck(:name).join(", ")
  end

  def tag_list=(names)
    self.media_tags = names.split(",").map(&:strip).reject(&:blank?).uniq.map do |name|
      MediaTag.find_or_create_by_name(name)
    end
  end

  def has_exif_data?
    exif_metadata.present? && exif_metadata.any?
  end

  private

  def extract_exif_from_uploaded_file(uploaded_file)
    return unless image?

    file_path = extract_file_path(uploaded_file)
    return if file_path.blank?

    result = ExifMetadataExtractor.call(file_path)
    self.exif_metadata = result[:all_tags]
    apply_suggested_values(result[:suggested_values])
    apply_tags_from_exif(result[:all_tags])
  rescue StandardError => e
    Rails.logger.error("Failed to extract EXIF: #{e.message}")
  end

  def extract_file_path(uploaded_file)
    case uploaded_file
    when ActionDispatch::Http::UploadedFile
      uploaded_file.tempfile.path
    when Rack::Test::UploadedFile
      uploaded_file.path
    when File, Tempfile
      uploaded_file.path
    end
  end

  def apply_suggested_values(suggested)
    return if suggested.blank?

    self.title = suggested[:title] if suggested[:title].present? && title.blank?
    self.description = suggested[:description] if suggested[:description].present? && description.blank?
    self.year = suggested[:year] if suggested[:year].present? && year.blank?
    self.copyright = suggested[:copyright] if suggested[:copyright].present? && copyright.blank?
    self.source = suggested[:source] if suggested[:source].present? && source.blank?
  end

  def apply_tags_from_exif(all_tags)
    return if all_tags.blank?

    keywords = extract_keywords_from_exif(all_tags)
    return if keywords.blank?

    self.media_tags = keywords.map { |name| MediaTag.find_or_create_by_name(name) }
  end

  def extract_keywords_from_exif(all_tags)
    keywords_value = all_tags["Keywords"] || all_tags["Subject"]
    return [] if keywords_value.blank?

    case keywords_value
    when Array
      keywords_value.map(&:strip).reject(&:blank?)
    when String
      keywords_value.split(/[,;]/).map(&:strip).reject(&:blank?)
    else
      []
    end
  end

  def should_sync_exif?
    image? && has_exif_data? && (title_changed? || description_changed?)
  end

  def sync_exif_metadata
    return unless exif_metadata.is_a?(Hash)

    if title_changed?
      exif_metadata["Title"] = title
      exif_metadata["ObjectName"] = title
      exif_metadata["Headline"] = title
    end

    if description_changed?
      exif_metadata["Description"] = description
      exif_metadata["ImageDescription"] = description
      exif_metadata["Caption-Abstract"] = description
    end
  end
end
