class CreateJcResults < ActiveRecord::Migration
  def self.up
    create_table :jc_results do |t|
      t.integer :c_result_id, null: false
      t.integer :judge_id, null: false
      t.integer :pilot_count
      t.integer :sigma_d2
      t.integer :sigma_pj
      t.integer :sigma_p2
      t.integer :sigma_j2
      t.decimal :sigma_ri_delta, precision: 11, scale: 5
      t.integer :con
      t.integer :dis
      t.integer :minority_zero_ct
      t.integer :minority_grade_ct
      t.boolean :need_compute

      t.timestamps
    end
  end

  def self.down
    drop_table :jc_results
  end
end
