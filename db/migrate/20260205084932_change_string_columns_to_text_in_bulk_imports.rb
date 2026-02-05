class ChangeStringColumnsToTextInBulkImports < ActiveRecord::Migration[8.1]
  def up
    change_column :bulk_imports, :import_type, :text, null: false, default: "zip"
    change_column :bulk_imports, :status, :text, null: false, default: "pending"
  end

  def down
    change_column :bulk_imports, :import_type, :string, null: false, default: "zip"
    change_column :bulk_imports, :status, :string, null: false, default: "pending"
  end
end
