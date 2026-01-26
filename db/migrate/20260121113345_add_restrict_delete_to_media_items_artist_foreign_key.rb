class AddRestrictDeleteToMediaItemsArtistForeignKey < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :media_items, :artists
    add_foreign_key :media_items, :artists, on_delete: :restrict
  end
end
