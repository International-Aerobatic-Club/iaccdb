class AddComputationCache < ActiveRecord::Migration
  def self.up
    create_table :pfj_results do |t|
      t.integer :pilot_flight_id, null: false
      t.integer :judge_id, null: false
      t.string :computed_values
      t.string :computed_ranks
      t.integer :flight_value
      t.integer :flight_rank
      t.timestamps
    end
    create_table :pf_results do |t|
      t.integer :pilot_flight_id, null: false
      t.decimal :flight_value, precision: 7, scale: 2
      t.decimal :adj_flight_value, precision: 7, scale: 2
      t.integer :flight_rank
      t.timestamps
    end
    create_table :pc_results do |t|
      t.integer :pilot_id, null: false
      t.integer :contest_id, null: false
      t.string :category, limit: 16, null: false
      t.decimal :category_value, precision: 8, scale: 2
      t.integer :category_rank
      t.timestamps
    end
  end

  def self.down
    drop_table :pfj_results
    drop_table :pf_results
    drop_table :pc_results
  end
end
