class AddCategoryToRegionalPilots < ActiveRecord::Migration
  def self.up
    add_column :regional_pilots, :category_id, :integer
  end

  def self.down
    remove_column :regional_pilots, :category_id
  end
end
