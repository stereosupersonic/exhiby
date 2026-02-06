class RenameErrorsToErrorMessagesInBulkImports < ActiveRecord::Migration[8.1]
  def change
    rename_column :bulk_imports, :errors, :error_messages
  end
end
