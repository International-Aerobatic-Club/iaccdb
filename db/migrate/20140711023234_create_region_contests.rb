class CreateRegionContests < ActiveRecord::Migration
  def self.up
    create_table :region_contests do |t|
      t.integer :pc_result_id
      t.integer :regional_pilot_id

      t.timestamps
    end
  end

  def self.down
    drop_table :region_contests
  end
end
