class IndexCategoriesFlights < ActiveRecord::Migration[5.1]
  def change
    add_index(:categories_flights, [:category_id, :flight_id], unique: true)
  end
end
