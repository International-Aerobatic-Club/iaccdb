class AddZeroCounts < ActiveRecord::Migration
  def self.up
    change_table :jf_results do |t|
      t.integer :minority_zero_ct, default: 0
      t.integer :minority_grade_ct, default: 0
    end
  end

  def self.down
    change_table :jf_results do |t|
      t.remove :minority_zero_ct
      t.remove :minority_grade_ct
    end
  end
end
