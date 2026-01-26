class AddCoverMediaItemToArticles < ActiveRecord::Migration[8.1]
  def change
    add_reference :articles, :cover_media_item, null: true, foreign_key: { to_table: :media_items }
  end
end
