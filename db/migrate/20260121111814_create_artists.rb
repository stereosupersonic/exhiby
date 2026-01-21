class CreateArtists < ActiveRecord::Migration[8.0]
  def change
    create_table :artists do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.date :birth_date
      t.date :death_date
      t.string :birth_place
      t.string :death_place
      t.string :status, null: false, default: "draft"
      t.datetime :published_at
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :artists, :slug, unique: true
    add_index :artists, :status
    add_index :artists, :published_at
  end
end
