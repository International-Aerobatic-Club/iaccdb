class AddTimestampsToSequences < ActiveRecord::Migration
  def self.up
    change_table :sequences do |t|
      t.timestamps
    end
  end

  def self.down
    change_table :sequences do |t|
      remove_column :updated_at
      remove_column :created_at
    end
  end
end
