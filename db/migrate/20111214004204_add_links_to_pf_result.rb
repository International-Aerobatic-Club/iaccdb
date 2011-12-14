class AddLinksToPfResult < ActiveRecord::Migration
  def self.up
    change_table :pf_results do |t|
      t.integer :f_result_id
    end
  end

  def self.down
    change_table :pf_results do |t|
      t.remove :f_result_id
    end
  end
end
