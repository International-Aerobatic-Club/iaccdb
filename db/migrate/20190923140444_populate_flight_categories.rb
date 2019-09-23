class PopulateFlightCategories < ActiveRecord::Migration[5.1]
  def up
    query = <<~SQL
      INSERT INTO categories_flights (flight_id, category_id)
        SELECT id, category_id
        FROM flights
    SQL
    exec_query query
  end
end
