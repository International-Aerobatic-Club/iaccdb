class CategoryCleanup < ActiveRecord::Migration
  def self.up
    remove_column :flights, :category
    remove_column :flights, :aircat
    remove_index :c_results, name: 'c_contest_category'
    remove_column :c_results, :category
    remove_column :c_results, :aircat
  end

  def self.down
  end
end
