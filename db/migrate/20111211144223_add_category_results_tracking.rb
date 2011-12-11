class AddCategoryResultsTracking < ActiveRecord::Migration
  def self.up
    create_table :c_results do |t|
      t.integer :contest_id
      t.string :category
      t.boolean :need_compute, :default => true
      t.timestamps
    end
    add_index (:c_results, [:contest_id, :category], 
      :name => :c_contest_category)
    add_index (:pc_results, [:contest_id, :category], 
      :name => :pc_contest_category)
  end

  def self.down
    drop_table :c_results
    remove_index :c_results, :name => :c_contest_category
    remove_index :pc_results, :name => :pc_contest_category
  end
end
