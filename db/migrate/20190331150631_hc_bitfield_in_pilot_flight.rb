class HcBitfieldInPilotFlight < ActiveRecord::Migration[5.1]
  def change
    change_column(:pilot_flights, :hors_concours, :integer,
      limit: 2, default: 0, null: false)
  end
end
