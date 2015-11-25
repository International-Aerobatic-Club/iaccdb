class NullDefaultForCResult < ActiveRecord::Migration
  def up
    change_column(:jc_results, :c_result_id, :integer, null:true)
  end
  def down
    change_column(:jc_results, :c_result_id, :integer, null:false)
  end
end
