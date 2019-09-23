class AddMultipleCategoriesForFlights < ActiveRecord::Migration[5.1]
  def change
    create_table :categories_flights, id: false do |t|
      t.references :flight, type: :integer, null: false, foreign_key: true
      t.references :category, type: :integer, null: false, foreign_key: true
    end
  end
end
