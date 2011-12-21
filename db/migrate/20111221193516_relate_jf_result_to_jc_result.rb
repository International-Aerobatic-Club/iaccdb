class RelateJfResultToJcResult < ActiveRecord::Migration
  def self.up
    add_column :jf_results, :jc_result_id, :integer
  end

  def self.down
    remove_column :jf_results, :jc_result_id
  end
end
