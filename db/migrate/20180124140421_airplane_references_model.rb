class AirplaneReferencesModel < ActiveRecord::Migration
  def change
    change_table :airplanes do |airplanes|
      airplanes.references :model
    end
  end
end
