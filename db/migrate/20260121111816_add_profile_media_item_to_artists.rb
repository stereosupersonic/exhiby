class AddProfileMediaItemToArtists < ActiveRecord::Migration[8.1]
  def change
    add_reference :artists, :profile_media_item, foreign_key: { to_table: :media_items }
  end
end
