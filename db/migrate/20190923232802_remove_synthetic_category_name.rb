class RemoveSyntheticCategoryName < ActiveRecord::Migration[5.1]
  def change
    remove_column :synthetic_categories, :synthetic_category_name, :string
  end
end
