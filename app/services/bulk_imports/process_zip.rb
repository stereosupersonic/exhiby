module BulkImports
  class ProcessZip < BaseService
    attr_reader :bulk_import

    def initialize(bulk_import)
      @bulk_import = bulk_import
    end

    def call
      bulk_import.start_processing!

      extract_dir = Rails.root.join("tmp", "bulk_imports", bulk_import.id.to_s)
      zip_path = download_zip_file

      extract_result = extract_zip(zip_path, extract_dir)
      return handle_extraction_failure(extract_result) unless extract_result[:success]

      csv_result = parse_csv(extract_result[:csv_file])
      csv_metadata = csv_result[:success] ? csv_result[:metadata] : {}

      bulk_import.update!(total_files: extract_result[:file_count])

      process_images(extract_result[:extracted_files], csv_metadata)

      bulk_import.complete!
      { success: true, bulk_import: bulk_import.reload }
    rescue StandardError => e
      Rails.logger.error("Bulk import #{bulk_import.id} failed: #{e.message}\n#{e.backtrace.first(10).join("\n")}")
      bulk_import.fail!(e.message)
      { success: false, error: e.message }
    ensure
      cleanup(extract_dir, zip_path)
    end

    private

    def download_zip_file
      raise "No file attached to bulk import" unless bulk_import.file.attached?

      temp_file = Tempfile.new([ "bulk_import", ".zip" ], binmode: true)
      temp_file.write(bulk_import.file.download)
      temp_file.rewind
      temp_file.path
    end

    def extract_zip(zip_path, extract_dir)
      ZipExtractor.call(zip_path, extract_dir)
    end

    def parse_csv(csv_file)
      return { success: true, metadata: {} } if csv_file.blank?

      CsvParser.call(csv_file)
    end

    def process_images(extracted_files, csv_metadata)
      extracted_files.each do |file_info|
        process_single_image(file_info, csv_metadata)
      end
    end

    def process_single_image(file_info, csv_metadata)
      filename = file_info[:filename]
      normalized_filename = filename.downcase

      metadata = csv_metadata[normalized_filename] || {}

      result = ProcessSingleImage.call(
        file_path: file_info[:path],
        filename: filename,
        csv_metadata: metadata,
        bulk_import: bulk_import,
        user: bulk_import.created_by
      )

      log_result(result)
      update_counters(result)
    end

    def log_result(result)
      entry = {
        filename: result[:filename],
        success: result[:success],
        processed_at: Time.current.iso8601
      }

      if result[:success]
        entry[:media_item_id] = result[:media_item_id]
        entry[:attribute_sources] = result[:attribute_sources]
      else
        entry[:errors] = result[:errors]
      end

      bulk_import.add_log_entry(entry)
    end

    def update_counters(result)
      bulk_import.increment_processed!

      if result[:success]
        bulk_import.increment_successful!
      else
        bulk_import.increment_failed!
      end
    end

    def handle_extraction_failure(result)
      bulk_import.fail!(result[:error])
      { success: false, error: result[:error] }
    end

    def cleanup(extract_dir, zip_path)
      FileUtils.rm_rf(extract_dir) if extract_dir && Dir.exist?(extract_dir.to_s)
      File.delete(zip_path) if zip_path && File.exist?(zip_path.to_s) && zip_path.is_a?(String)
    rescue StandardError => e
      Rails.logger.warn("Cleanup failed: #{e.message}")
    end
  end
end
