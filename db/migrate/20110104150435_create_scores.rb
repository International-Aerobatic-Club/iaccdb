class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.integer :pilot_flight_id
      t.integer :judge_id
      t.string :values

      t.timestamps
    end
  end

  def self.down
    drop_table :scores
  end
end
