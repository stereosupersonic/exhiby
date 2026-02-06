class AddPhashToMediaItems < ActiveRecord::Migration[8.1]
  def change
    add_column :media_items, :phash, :text
    add_column :media_items, :phash_calculated_at, :datetime
    add_index :media_items, :phash
  end
end
