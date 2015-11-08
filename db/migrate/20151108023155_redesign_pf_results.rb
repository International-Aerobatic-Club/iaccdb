class RedesignPfResults < ActiveRecord::Migration
  def up
    remove_index :pf_results, :pc_result_id
    remove_column :pf_results, :pc_result_id
    remove_index :pf_results, :f_result_id
    remove_column :pf_results, :f_result_id
  end
  def down
    add_column :pf_results, :pc_result_id, :integer
    add_index :pf_results, :pc_result_id
    add_column :pf_results, :f_result_id, :integer
    add_index :pf_results, :f_result_id
  end
end
