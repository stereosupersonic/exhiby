module BulkImports
  class DuplicateDetector < BaseService
    attr_reader :phash, :batch_phashes

    def initialize(phash, batch_phashes: {})
      @phash = phash
      @batch_phashes = batch_phashes || {}
    end

    def call
      return not_duplicate if phash.blank?

      batch_match = check_batch_duplicates
      return batch_match if batch_match[:duplicate]

      database_match = check_database_duplicates
      return database_match if database_match[:duplicate]

      not_duplicate
    end

    private

    def check_batch_duplicates
      if batch_phashes.key?(phash)
        match_info = batch_phashes[phash]
        {
          duplicate: true,
          match_type: :batch,
          existing_media_item_id: match_info[:id],
          existing_title: match_info[:filename] || match_info[:title],
          similarity_percentage: 100
        }
      else
        not_duplicate
      end
    end

    def check_database_duplicates
      existing = MediaItem.where(phash: phash).first

      if existing
        {
          duplicate: true,
          match_type: :database,
          existing_media_item_id: existing.id,
          existing_title: existing.title,
          similarity_percentage: 100
        }
      else
        not_duplicate
      end
    end

    def not_duplicate
      { duplicate: false }
    end
  end
end
