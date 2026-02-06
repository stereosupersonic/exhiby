require "csv"

module BulkImports
  class CsvParser < BaseService
    EXPECTED_HEADERS = %w[
      filename title description year source copyright tags artist_name technique_name
    ].freeze

    ENCODING_OPTIONS = [
      "UTF-8",
      "ISO-8859-1",
      "Windows-1252"
    ].freeze

    attr_reader :csv_path

    def initialize(csv_path)
      @csv_path = csv_path
    end

    def call
      return empty_result unless csv_path.present? && File.exist?(csv_path)

      content = read_with_encoding
      return { success: false, error: "Could not read CSV file with any supported encoding" } if content.nil?

      parse_csv(content)
    rescue CSV::MalformedCSVError => e
      { success: false, error: "Malformed CSV: #{e.message}" }
    end

    private

    def read_with_encoding
      ENCODING_OPTIONS.each do |encoding|
        content = File.read(csv_path, encoding: "#{encoding}:UTF-8")
        return content.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
      rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
        next
      end
      nil
    end

    def parse_csv(content)
      rows = CSV.parse(content, headers: true, skip_blanks: true, liberal_parsing: true)

      return empty_result if rows.empty?

      metadata_by_filename = {}
      rows.each do |row|
        filename = normalize_filename(row["filename"])
        next if filename.blank?

        metadata_by_filename[filename] = extract_metadata(row)
      end

      {
        success: true,
        metadata: metadata_by_filename,
        row_count: metadata_by_filename.count,
        headers: rows.headers
      }
    end

    def normalize_filename(filename)
      return nil if filename.blank?

      filename.to_s.strip.downcase
    end

    def extract_metadata(row)
      {
        title: clean_value(row["title"]),
        description: clean_value(row["description"]),
        year: parse_year(row["year"]),
        source: clean_value(row["source"]),
        copyright: clean_value(row["copyright"]),
        tags: parse_tags(row["tags"]),
        artist_name: clean_value(row["artist_name"]),
        technique_name: clean_value(row["technique_name"])
      }.compact
    end

    def clean_value(value)
      return nil if value.blank?

      value.to_s.strip.presence
    end

    def parse_year(value)
      return nil if value.blank?

      year = value.to_s.strip.to_i
      year.positive? && year <= Time.current.year ? year : nil
    end

    def parse_tags(value)
      return [] if value.blank?

      value.to_s.split(/[;,]/).map(&:strip).reject(&:blank?).uniq
    end

    def empty_result
      {
        success: true,
        metadata: {},
        row_count: 0,
        headers: []
      }
    end
  end
end
