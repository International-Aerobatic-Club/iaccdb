class CreateJudges < ActiveRecord::Migration
  def self.up
    create_table :judges do |t|
      t.integer :judge
      t.integer :assist

      t.timestamps
    end
  end

  def self.down
    drop_table :judges
  end
end
