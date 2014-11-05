class IndexResultAccums < ActiveRecord::Migration
  def up
    change_table :result_accums do |t|
      t.index :result_id
      t.index :pc_result_id
      t.index [:result_id, :pc_result_id], :unique => true
    end
  end
  def down
  end
end
