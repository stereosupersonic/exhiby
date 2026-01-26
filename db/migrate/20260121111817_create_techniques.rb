class CreateTechniques < ActiveRecord::Migration[8.1]
  def change
    create_table :techniques do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end
    add_index :techniques, :name, unique: true
    add_index :techniques, :slug, unique: true
    add_index :techniques, :position
  end
end
