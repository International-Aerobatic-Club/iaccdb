class HcBitfieldInPcResults < ActiveRecord::Migration[5.1]
  def change
    change_column(:pc_results, :hors_concours, :integer,
      limit: 2, default: 0, null: false)
  end
end
