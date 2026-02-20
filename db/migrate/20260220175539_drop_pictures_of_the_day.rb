class DropPicturesOfTheDay < ActiveRecord::Migration[8.1]
  def up
    drop_table :pictures_of_the_day
  end

  def down
    create_table :pictures_of_the_day do |t|
      t.references :media_item, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.date :display_date, null: false
      t.text :caption
      t.text :description

      t.timestamps
    end

    add_index :pictures_of_the_day, :display_date, unique: true
  end
end
