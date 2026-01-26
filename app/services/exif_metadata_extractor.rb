class ExifMetadataExtractor < BaseService
  # Tags to extract and display (grouped by category)
  DISPLAY_TAGS = {
    camera: %w[
      Make Model LensModel LensInfo
    ],
    image: %w[
      ImageWidth ImageHeight Orientation ColorSpace
      BitsPerSample Compression PhotometricInterpretation
    ],
    capture: %w[
      ExposureTime FNumber ISO FocalLength
      ExposureProgram ExposureCompensation MeteringMode
      Flash WhiteBalance DigitalZoomRatio
    ],
    date: %w[
      DateTimeOriginal CreateDate ModifyDate
    ],
    location: %w[
      GPSLatitude GPSLongitude GPSAltitude
      GPSLatitudeRef GPSLongitudeRef
    ],
    author: %w[
      Artist Copyright Creator Rights
      CopyrightNotice Credit
    ],
    description: %w[
      Title Description Subject Keywords
      Caption-Abstract Headline ObjectName
    ]
  }.freeze

  ALL_DISPLAY_TAGS = DISPLAY_TAGS.values.flatten.freeze

  # Mapping EXIF tags to MediaItem fields for auto-fill
  FIELD_MAPPINGS = {
    title: %w[Title ObjectName Headline],
    description: %w[Description Caption-Abstract Subject],
    year: %w[DateTimeOriginal CreateDate],
    copyright: %w[Copyright CopyrightNotice Rights Credit],
    source: %w[Artist Creator]
  }.freeze

  attr_reader :file_path

  def initialize(file_path)
    @file_path = file_path
  end

  def call
    return empty_result unless file_path.present? && File.exist?(file_path)

    begin
      exif = MiniExiftool.new(file_path)
      build_result(exif)
    rescue MiniExiftool::Error => e
      Rails.logger.error("EXIF extraction failed: #{e.message}")
      empty_result
    end
  end

  private

  def build_result(exif)
    {
      all_tags: extract_all_tags(exif),
      grouped_tags: extract_grouped_tags(exif),
      suggested_values: extract_suggested_values(exif),
      raw_tags_count: exif.to_hash.keys.count
    }
  end

  def extract_all_tags(exif)
    exif.to_hash.transform_values { |v| format_value(v) }
  end

  def extract_grouped_tags(exif)
    DISPLAY_TAGS.transform_values do |tags|
      tags.each_with_object({}) do |tag, hash|
        value = exif[tag]
        hash[tag] = format_value(value) if value.present?
      end.presence
    end.compact
  end

  def extract_suggested_values(exif)
    FIELD_MAPPINGS.transform_values do |tags|
      value = tags.lazy.map { |tag| exif[tag] }.find(&:present?)
      format_for_field(value)
    end.compact
  end

  def format_value(value)
    case value
    when Time, DateTime
      value.strftime("%Y-%m-%d %H:%M:%S")
    when Float
      value.round(4)
    when Array
      value.join(", ")
    else
      value.to_s
    end
  end

  def format_for_field(value)
    return nil if value.blank?

    case value
    when Time, DateTime
      value.year
    else
      value.to_s.strip
    end
  end

  def empty_result
    {
      all_tags: {},
      grouped_tags: {},
      suggested_values: {},
      raw_tags_count: 0
    }
  end
end
