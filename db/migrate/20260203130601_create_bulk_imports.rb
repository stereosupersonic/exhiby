class CreateBulkImports < ActiveRecord::Migration[8.1]
  def change
    create_table :bulk_imports do |t|
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :import_type, null: false, default: "zip"
      t.string :status, null: false, default: "pending"
      t.integer :total_files, null: false, default: 0
      t.integer :processed_files, null: false, default: 0
      t.integer :successful_imports, null: false, default: 0
      t.integer :failed_imports, null: false, default: 0
      t.jsonb :import_log, null: false, default: []
      t.jsonb :errors, null: false, default: []
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :bulk_imports, :import_type
    add_index :bulk_imports, :status
    add_index :bulk_imports, :created_at
  end
end
