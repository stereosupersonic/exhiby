class CreatePicturesOfTheDay < ActiveRecord::Migration[8.1]
  def change
    create_table :pictures_of_the_day do |t|
      t.references :media_item, null: false, foreign_key: { on_delete: :restrict }
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.date :display_date, null: false
      t.string :caption
      t.text :description

      t.timestamps
    end

    add_index :pictures_of_the_day, :display_date, unique: true
  end
end
