class CreateJfResults < ActiveRecord::Migration
  def self.up
    create_table :jf_results do |t|
      t.integer :f_result_id, null: :false
      t.integer :judge_id, null: :false
      t.integer :pilot_count
      t.integer :sigma_d2
      t.integer :sigma_pj
      t.integer :sigma_p2
      t.integer :sigma_j2
      t.decimal :sigma_ri_delta, precision: 10, scale: 5
      t.integer :con
      t.integer :dis

      t.timestamps
    end
  end

  def self.down
    drop_table :jf_results
  end
end
