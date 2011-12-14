class AddPcResultToPfResult < ActiveRecord::Migration
  def self.up
    change_table :pf_results do |t|
      t.integer :pc_result_id
    end
  end

  def self.down
    change_table :pf_results do |t|
      t.remove :pc_result_id
    end
  end
end
