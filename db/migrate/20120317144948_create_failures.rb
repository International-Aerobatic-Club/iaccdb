class CreateFailures < ActiveRecord::Migration
  def self.up
    create_table :failures do |t|
      t.string :step, :limit => 16
      t.integer :contest_id
      t.integer :manny_id
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :failures
  end
end
