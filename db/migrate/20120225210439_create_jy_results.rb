class CreateJyResults < ActiveRecord::Migration
  def self.up
    create_table :jy_results do |t|
      t.integer :judge_id
      t.integer :category_id
      t.integer :year
      t.integer :pilot_count
      t.integer :ftsdxdy
      t.integer :ftsdx2
      t.integer :ftsdy2
      t.integer :con
      t.integer :dis
      t.integer :pair_count
      t.decimal :avgFlightSize, precision: 5, scale: 2
      t.integer :flight_count
      t.integer :grade_count
      t.decimal :avgK, precision: 5, scale: 2
      t.integer :minority_zero_count
      t.integer :minority_grade_count
      t.decimal :sigma_ri_delta, precision: 12, scale: 5

      t.timestamps
    end
  end

  def self.down
    drop_table :jy_results
  end
end
