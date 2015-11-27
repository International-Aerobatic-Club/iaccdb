class AddFlightToJfResult < ActiveRecord::Migration
  def change
    add_column :jf_results, :flight_id, :integer
    add_index :jf_results, :flight_id
  end
end
