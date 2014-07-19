class AddTotalPossible < ActiveRecord::Migration
  def self.up
    add_column :pc_results, 'total_possible', :integer
    add_column :pf_results, 'total_possible', :integer
  end

  def self.down
    remove_column :pc_results, 'total_possible'
    remove_column :pf_results, 'total_possible'
  end
end
