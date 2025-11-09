class AddFlightAndCategoryResultsTracking < ActiveRecord::Migration
  def self.up
    create_table :f_results, force: true do |t|
      t.integer :flight_id
      t.boolean :need_compute, default: true
      t.timestamps
    end
  end

  def self.down
    drop_table :f_results
  end
end
