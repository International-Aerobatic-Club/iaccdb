class AddFigureResultsAndAdjFlightRankToPfResults < ActiveRecord::Migration
  def self.up
    change_table :pf_results do |t|
      t.string :figure_results
      t.integer :adj_flight_rank
    end
  end

  def self.down
    change_table :pf_results do |t|
      t.remove_column :figure_results
      t.remove_column :adj_flight_rank
    end
  end
end
