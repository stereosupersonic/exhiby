class CreateMediaItems < ActiveRecord::Migration[8.1]
  def change
    create_table :media_items do |t|
      t.string :title, null: false
      t.text :description
      t.string :media_type, null: false
      t.integer :year
      t.string :source
      t.string :technique
      t.string :copyright
      t.string :license
      t.string :status, null: false, default: "draft"
      t.datetime :published_at
      t.datetime :submitted_at
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :media_items, :status
    add_index :media_items, :media_type
    add_index :media_items, :year
    add_index :media_items, :published_at
  end
end
