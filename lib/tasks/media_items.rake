namespace :media_items do
  desc "Calculate and store perceptual hash for all images without phash"
  task backfill_phash: :environment do
    images_without_phash = MediaItem.without_phash.where(media_type: "image")
    total = images_without_phash.count

    if total.zero?
      puts "All images already have phash values. Nothing to do."
      exit
    end

    puts "Backfilling phash for #{total} images..."
    puts ""

    processed = 0
    success = 0
    failed = 0
    skipped = 0

    images_without_phash.find_each do |media_item|
      processed += 1
      progress = ((processed.to_f / total) * 100).round(1)

      print "\r[#{progress_bar(progress)}] #{progress}% (#{processed}/#{total}) - Success: #{success}, Failed: #{failed}, Skipped: #{skipped}"

      unless media_item.file.attached?
        skipped += 1
        next
      end

      begin
        file_path = extract_file_path(media_item)

        if file_path.blank?
          skipped += 1
          next
        end

        phash = PerceptualHashCalculator.call(file_path)

        if phash.present?
          media_item.update_columns(phash: phash, phash_calculated_at: Time.current)
          success += 1
        else
          failed += 1
        end
      rescue StandardError => e
        Rails.logger.error("Failed to calculate phash for MediaItem##{media_item.id}: #{e.message}")
        failed += 1
      ensure
        cleanup_tempfile
      end
    end

    puts "\n\n"
    puts "=" * 50
    puts "Backfill complete!"
    puts "=" * 50
    puts "  Total processed: #{processed}"
    puts "  Success:         #{success}"
    puts "  Failed:          #{failed}"
    puts "  Skipped:         #{skipped}"
    puts ""
  end

  def progress_bar(percentage, width = 30)
    filled = (percentage / 100.0 * width).round
    empty = width - filled
    "#" * filled + "-" * empty
  end

  def extract_file_path(media_item)
    blob = media_item.file.blob

    if blob.service.respond_to?(:path_for)
      blob.service.path_for(blob.key)
    else
      @_tempfile = Tempfile.new([ "phash", File.extname(media_item.file.filename.to_s) ])
      @_tempfile.binmode
      @_tempfile.write(media_item.file.download)
      @_tempfile.close
      @_tempfile.path
    end
  end

  def cleanup_tempfile
    return unless @_tempfile

    @_tempfile.unlink
    @_tempfile = nil
  rescue StandardError
    nil
  end
end
