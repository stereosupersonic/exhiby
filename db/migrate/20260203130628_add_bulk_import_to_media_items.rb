class AddBulkImportToMediaItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :media_items, :bulk_import, foreign_key: true, null: true
  end
end
