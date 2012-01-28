class AddPairCountToJcResults < ActiveRecord::Migration
  def self.up
    add_column :jc_results, :pair_count, :integer
  end

  def self.down
    remove_column :jc_results, :pair_count
  end
end
