class CreateSyntheticCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :synthetic_categories, id: :integer do |t|
      t.references :contest, type: :integer, foreign_key: true
      t.references :regular_category, type: :integer
      t.text :regular_category_flights
      t.string :synthetic_category_name
      t.string :synthetic_category_description
      t.text :synthetic_category_flights

      t.foreign_key(:categories, column: :regular_category_id,
        on_delete: :cascade, on_update: :cascade)
      t.timestamps
    end
  end
end
