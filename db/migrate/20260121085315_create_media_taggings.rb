class CreateMediaTaggings < ActiveRecord::Migration[8.1]
  def change
    create_table :media_taggings do |t|
      t.references :media_item, null: false, foreign_key: true
      t.references :media_tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :media_taggings, [ :media_item_id, :media_tag_id ], unique: true
  end
end
