class CreatePilotFlights < ActiveRecord::Migration
  def self.up
    create_table :pilot_flights do |t|
      t.integer :pilot_id
      t.integer :flight_id
      t.integer :sequence_id
      t.integer :aircraft_id
      t.string :chapter, limit: 8

      t.timestamps
    end
  end

  def self.down
    drop_table :pilot_flights
  end
end
