class AddStarToPcResult < ActiveRecord::Migration
  def self.up
    add_column :pc_results, :star_qualifying, :boolean, :default => false
  end

  def self.down
    remove_column :pc_results, :star_qualifying
  end
end
