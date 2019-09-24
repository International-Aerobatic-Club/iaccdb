class LengthenContestCategoryName < ActiveRecord::Migration[5.1]
  def up
    change_column :categories, :name, :string, limit: 48, null: false
    change_column :synthetic_categories, :synthetic_category_description,
      :string, limit: 48, null: false
  end
  def down
    change_column :categories, :name, :string, limit: 32, null: false
    change_column :synthetic_categories, :synthetic_category_description,
      :string, null: true
  end
end
