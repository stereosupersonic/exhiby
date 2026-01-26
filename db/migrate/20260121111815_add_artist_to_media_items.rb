class AddArtistToMediaItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :media_items, :artist, foreign_key: true, null: true
  end
end
