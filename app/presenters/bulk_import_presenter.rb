class BulkImportPresenter < ApplicationPresenter
  STATUS_BADGE_CLASSES = {
    "pending" => "bg-secondary",
    "processing" => "bg-info",
    "completed" => "bg-success",
    "failed" => "bg-danger"
  }.freeze

  SOURCE_BADGE_CLASSES = {
    "csv" => "bg-primary",
    "exif" => "bg-info",
    "filename" => "bg-secondary"
  }.freeze

  def status_badge_class
    STATUS_BADGE_CLASSES.fetch(o.status, "bg-secondary")
  end

  def status_name
    I18n.t("bulk_import_statuses.#{o.status}")
  end

  def source_badge_class(source)
    self.class.source_badge_class(source)
  end

  def source_name(source)
    self.class.source_name(source)
  end

  def self.source_badge_class(source)
    SOURCE_BADGE_CLASSES.fetch(source.to_s, "bg-secondary")
  end

  def self.source_name(source)
    I18n.t("bulk_import_sources.#{source}")
  end

  def creator_name
    o.created_by.email_address
  end

  def formatted_created_at
    I18n.l(o.created_at, format: :long)
  end

  def formatted_started_at
    return nil unless o.started_at

    I18n.l(o.started_at, format: :long)
  end

  def formatted_completed_at
    return nil unless o.completed_at

    I18n.l(o.completed_at, format: :long)
  end

  def formatted_duration
    return nil unless o.duration

    seconds = o.duration.to_i
    if seconds < 60
      I18n.t("admin.bulk_imports.duration.seconds", count: seconds)
    elsif seconds < 3600
      minutes = (seconds / 60.0).round(1)
      I18n.t("admin.bulk_imports.duration.minutes", count: minutes)
    else
      hours = (seconds / 3600.0).round(1)
      I18n.t("admin.bulk_imports.duration.hours", count: hours)
    end
  end

  def file_info
    return nil unless o.file.attached?

    filename = o.file.filename.to_s
    size = number_to_human_size(o.file.byte_size)
    "#{filename} (#{size})"
  end

  def progress_bar_class
    case o.status
    when "processing"
      "progress-bar-striped progress-bar-animated bg-info"
    when "completed"
      "bg-success"
    when "failed"
      "bg-danger"
    else
      "bg-secondary"
    end
  end

  def log_entries
    o.import_log.map do |entry|
      LogEntry.new(entry)
    end
  end

  def successful_log_entries
    log_entries.select(&:success?)
  end

  def failed_log_entries
    log_entries.reject(&:success?)
  end

  def duplicate_log_entries
    log_entries.select(&:duplicate?)
  end

  class LogEntry
    attr_reader :data

    def initialize(data)
      @data = data.with_indifferent_access
    end

    def filename
      data[:filename]
    end

    def success?
      data[:success]
    end

    def media_item_id
      data[:media_item_id]
    end

    def attribute_sources
      data[:attribute_sources] || {}
    end

    def errors
      data[:errors] || []
    end

    def duplicate?
      data[:duplicate] == true
    end

    def existing_media_item_id
      data[:existing_media_item_id]
    end

    def processed_at
      return nil unless data[:processed_at]

      Time.zone.parse(data[:processed_at])
    end
  end
end
