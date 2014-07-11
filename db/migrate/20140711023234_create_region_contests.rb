class CreateRegionContests < ActiveRecord::Migration
  def self.up
    create_table :region_contests do |t|
      t.id :pc_result_id
      t.id :regional_pilot_id

      t.timestamps
    end
  end

  def self.down
    drop_table :region_contests
  end
end
