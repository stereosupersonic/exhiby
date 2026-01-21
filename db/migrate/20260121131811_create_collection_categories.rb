class CreateCollectionCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :collection_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :collection_categories, :name, unique: true
    add_index :collection_categories, :slug, unique: true
    add_index :collection_categories, :position
  end
end
