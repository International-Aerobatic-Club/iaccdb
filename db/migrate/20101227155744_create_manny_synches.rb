class CreateMannySynches < ActiveRecord::Migration
  def self.up
    create_table :manny_synches do |t|
      t.integer :contest_id
      t.integer :manny_number
      t.datetime :synch_date

      t.timestamps
    end
  end

  def self.down
    drop_table :manny_synches
  end
end
