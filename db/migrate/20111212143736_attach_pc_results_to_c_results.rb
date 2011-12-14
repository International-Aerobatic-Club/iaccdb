class AttachPcResultsToCResults < ActiveRecord::Migration
  def self.up
    change_table :pc_results do |t|
      t.remove_index :name => "pc_contest_category"
      t.remove :contest_id
      t.remove :category
      t.remove :aircat
      t.integer :c_result_id
    end
  end

  def self.down
    change_table :pc_results do |t|
      t.remove :c_result_id
      t.string :aircat, :limit => 1
      t.string :category
      t.integer :contest_id
      t.index [:category, :aircat], :name => "pc_contest_category"
    end
  end
end
