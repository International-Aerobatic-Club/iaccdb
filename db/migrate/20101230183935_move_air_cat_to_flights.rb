class MoveAirCatToFlights < ActiveRecord::Migration
  def self.up
    remove_column :contests, :aircat
    add_column :flights, :aircat, :string, limit: 1
  end

  def self.down
    remove_column :flights, :aircat
    add_column :contests, :aircat, :string, limit: 1
  end
end
