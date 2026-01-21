class AddTechniqueRefToMediaItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :media_items, :technique, foreign_key: true
    rename_column :media_items, :technique, :technique_legacy
  end
end
