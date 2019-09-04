class RemoveAirplaneMakeModelColumns < ActiveRecord::Migration[5.1]
  def up
    remove_column :airplanes, :make
    remove_column :airplanes, :model
  end
  def down
    add_column :airplanes, :make, :string
    add_column :airplanes, :model, :string
  end
end
