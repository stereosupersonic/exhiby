class AddExifMetadataToMediaItems < ActiveRecord::Migration[8.1]
  def change
    add_column :media_items, :exif_metadata, :jsonb, default: {}
  end
end
