class AdjustForeignKeys < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :categories_flights, :categories
    remove_foreign_key :categories_flights, :flights
    remove_foreign_key :synthetic_categories, :contests
    add_foreign_key :categories_flights, :categories, on_delete: :cascade
    add_foreign_key :categories_flights, :flights, on_delete: :cascade
    add_foreign_key :synthetic_categories, :contests, on_delete: :cascade
  end
end
