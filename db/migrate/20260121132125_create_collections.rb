class CreateCollections < ActiveRecord::Migration[8.1]
  def change
    create_table :collections do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :position, default: 0, null: false
      t.string :status, default: "draft", null: false
      t.datetime :published_at
      t.references :collection_category, null: false, foreign_key: true
      t.references :cover_media_item, foreign_key: { to_table: :media_items }
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :collections, :slug, unique: true
    add_index :collections, :status
    add_index :collections, :published_at
    add_index :collections, [ :collection_category_id, :position ]
  end
end
