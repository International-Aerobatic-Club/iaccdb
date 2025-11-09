class CreateAirplanes < ActiveRecord::Migration
  def self.up
    create_table :airplanes do |t|
      t.string :make, length: 32
      t.string :model, length: 32
      t.string :reg, length: 8

      t.timestamps
    end
    rename_column :pilot_flights, :aircraft_id, :airplane_id
  end

  def self.down
    drop_table :airplanes
    rename_column :pilot_flights, :airplane_id, :aircraft_id
  end
end
