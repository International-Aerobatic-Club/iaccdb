class CreateFlights < ActiveRecord::Migration
  def self.up
    create_table :flights do |t|
      t.integer :contest, null: false
      t.string :category, limit: 16, null: false
      t.string :name, limit: 16, null: false
      t.integer :sequence, null: false
      t.integer :chief, null: false
      t.integer :assist, null: false

      t.timestamps
    end
  end

  def self.down
    drop_table :flights
  end
end
