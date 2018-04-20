class AirplaneAirplaneModel < ActiveRecord::Migration
  def change
    rename_table 'airplane_models', 'make_models'
    rename_column 'airplanes', 'airplane_model_id', 'make_model_id'
  end
end
