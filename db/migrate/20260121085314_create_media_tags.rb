class CreateMediaTags < ActiveRecord::Migration[8.1]
  def change
    create_table :media_tags do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :media_items_count, default: 0

      t.timestamps
    end

    add_index :media_tags, :name, unique: true
    add_index :media_tags, :slug, unique: true
  end
end
