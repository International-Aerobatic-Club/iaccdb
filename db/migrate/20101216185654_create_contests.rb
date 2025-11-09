class CreateContests < ActiveRecord::Migration
  def self.up
    create_table :contests do |t|
      t.string :name, limit: 48
      t.string :city, limit: 24
      t.string :state, limit: 2
      t.date :start
      t.integer :chapter
      t.string :director, limit: 48
      t.string :region, limit: 16
      t.integer :manny_id, null: false
      t.string :aircat, limit: 1

      t.timestamps
    end
  end

  def self.down
    drop_table :contests
  end
end
