class AddHorsConcours < ActiveRecord::Migration
  def change
    add_column :pilot_flights, :hors_concours,
        :boolean, null: false, default: false
    add_column :pc_results, :hors_concours,
        :boolean, null: false, default: false
  end
end
