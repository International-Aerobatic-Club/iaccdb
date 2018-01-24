class SeparateAirplaneMakeAndModel < ActiveRecord::Migration
  def change
    create_table :models do |models|
      models.string :make
      models.string :model
      models.integer :empty_weight_lbs, limit: 2
      models.integer :max_weight_lbs, limit: 2
      models.integer :horsepower, limit: 2
      models.integer :seats, limit: 1
      models.integer :wings, limit: 1
    end
  end
end
