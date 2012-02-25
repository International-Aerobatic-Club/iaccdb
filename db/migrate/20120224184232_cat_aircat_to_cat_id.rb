class CatAircatToCatId < ActiveRecord::Migration
  def self.up
    add_column :c_results, :category_id, :integer
    add_column :flights, :category_id, :integer
  end

  def self.down
    remove_column :c_results, :category_id
    remove_column :flights, :category_id
  end
end
