require "zip"

module BulkImports
  class ZipExtractor < BaseService
    MAX_EXTRACTED_SIZE = 2.gigabytes
    MAX_COMPRESSION_RATIO = 100
    IGNORED_PATTERNS = [
      /^__MACOSX\//,
      /\.DS_Store$/,
      /Thumbs\.db$/i,
      /\.gitkeep$/,
      /^\./
    ].freeze

    class ZipBombError < StandardError; end

    class PathTraversalError < StandardError; end

    class FileTooLargeError < StandardError; end

    attr_reader :zip_path, :extract_dir

    def initialize(zip_path, extract_dir)
      @zip_path = zip_path
      @extract_dir = extract_dir
    end

    def call
      validate_zip_file!
      FileUtils.mkdir_p(extract_dir)

      extracted_files = []
      csv_file = nil
      total_extracted_size = 0

      Zip::File.open(zip_path) do |zip_file|
        zip_file.each do |entry|
          next if skip_entry?(entry)

          safe_path = safe_extract_path(entry.name)
          entry_size = entry.size

          validate_entry!(entry, total_extracted_size, entry_size)
          total_extracted_size += entry_size

          full_path = File.join(extract_dir, safe_path)
          FileUtils.mkdir_p(File.dirname(full_path))
          entry.extract(full_path)

          if csv_file?(safe_path)
            csv_file = full_path
          elsif image_file?(safe_path)
            extracted_files << {
              path: full_path,
              filename: File.basename(safe_path)
            }
          end
        end
      end

      {
        success: true,
        extracted_files: extracted_files,
        csv_file: csv_file,
        total_size: total_extracted_size,
        file_count: extracted_files.count
      }
    rescue Zip::Error => e
      { success: false, error: "Invalid ZIP file: #{e.message}" }
    rescue ZipBombError => e
      { success: false, error: e.message }
    rescue PathTraversalError => e
      { success: false, error: e.message }
    rescue FileTooLargeError => e
      { success: false, error: e.message }
    end

    private

    def validate_zip_file!
      raise ArgumentError, "ZIP file does not exist" unless File.exist?(zip_path)
    end

    def skip_entry?(entry)
      return true if entry.directory?
      return true if entry.name.blank?

      IGNORED_PATTERNS.any? { |pattern| entry.name.match?(pattern) }
    end

    def safe_extract_path(entry_name)
      path = entry_name.tr("\\", "/")

      if path.include?("..") || path.start_with?("/")
        raise PathTraversalError, "Path traversal detected in: #{entry_name}"
      end

      path.split("/").last || entry_name
    end

    def validate_entry!(entry, current_total, entry_size)
      if current_total + entry_size > MAX_EXTRACTED_SIZE
        raise FileTooLargeError, "Extracted content exceeds maximum allowed size (#{MAX_EXTRACTED_SIZE / 1.gigabyte}GB)"
      end

      if entry.compressed_size > 0
        ratio = entry_size.to_f / entry.compressed_size
        if ratio > MAX_COMPRESSION_RATIO
          raise ZipBombError, "Suspicious compression ratio detected (#{ratio.round}:1). Possible ZIP bomb."
        end
      end
    end

    def csv_file?(path)
      File.extname(path).downcase == ".csv"
    end

    def image_file?(path)
      ext = File.extname(path).downcase
      %w[.jpg .jpeg .png .gif .webp .tiff .tif .bmp].include?(ext)
    end
  end
end
