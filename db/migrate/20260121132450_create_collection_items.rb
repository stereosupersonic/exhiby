class CreateCollectionItems < ActiveRecord::Migration[8.1]
  def change
    create_table :collection_items do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :media_item, null: false, foreign_key: true
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :collection_items, [:collection_id, :media_item_id], unique: true
    add_index :collection_items, [:collection_id, :position]
  end
end
