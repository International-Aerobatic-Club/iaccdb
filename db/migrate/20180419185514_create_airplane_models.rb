class CreateAirplaneModels < ActiveRecord::Migration
  def change
    rename_table 'models', 'airplane_models'
    rename_column 'airplanes', 'model_id', 'airplane_model_id'
    add_index 'airplane_models', 'id'
    add_index 'airplane_models', 'make'
    add_index 'airplane_models', 'model'
    add_index 'airplane_models', ['make', 'model'], unique: true
  end
end
