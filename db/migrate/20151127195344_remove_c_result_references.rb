class RemoveCResultReferences < ActiveRecord::Migration
  def up
    remove_index "jc_results", ["c_result_id"]
    remove_column "jc_results", "c_result_id"
    remove_index "pc_results", ["c_result_id"]
    remove_column "pc_results", "c_result_id"
    remove_index "jf_results", ["jc_result_id"]
    remove_column "jf_results", "jc_result_id"
    remove_index "jf_results", ["f_result_id"]
    remove_column "jf_results", "f_result_id"
  end
  def down
    add_column 'jc_results', 'c_result_id', :integer
    add_index "jc_results", ["c_result_id"], 
      name: "index_jc_results_on_c_result_id", using: :btree
    add_column 'pc_results', 'c_result_id', :integer
    add_index "pc_results", ["c_result_id"], 
      name: "index_pc_results_on_c_result_id", using: :btree
    add_column 'jf_results', 'jc_result_id', :integer
    add_index "jf_results", ["jc_result_id"],
      name: "index_jf_results_on_jc_result_id", using: :btree
    add_column 'jf_results', 'f_result_id', :integer
    add_index "jf_results", ["f_result_id"],
      name: "index_jf_results_on_f_result_id", using: :btree
  end
end
