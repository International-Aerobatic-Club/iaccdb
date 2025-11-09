class AddPenaltiesToPilotFlight < ActiveRecord::Migration
  def self.up
    add_column :pilot_flights, :penalty_total, :integer, default: 0 
  end

  def self.down
    remove_column :pilot_flights, :penalty_total
  end
end
