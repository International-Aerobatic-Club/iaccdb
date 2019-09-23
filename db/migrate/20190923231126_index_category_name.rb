class IndexCategoryName < ActiveRecord::Migration[5.1]
  def change
    add_index :categories, [:category, :aircat, :name], unique: true
  end
end
