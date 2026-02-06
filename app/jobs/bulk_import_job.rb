class BulkImportJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 3
  discard_on ActiveJob::DeserializationError

  def perform(bulk_import_id)
    bulk_import = BulkImport.find(bulk_import_id)

    return if bulk_import.processing? || bulk_import.completed?

    case bulk_import.import_type
    when "zip"
      BulkImports::ProcessZip.call(bulk_import)
    else
      bulk_import.fail!("Unknown import type: #{bulk_import.import_type}")
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("BulkImport not found: #{bulk_import_id}")
  end
end
