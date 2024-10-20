class RemoveManny < ActiveRecord::Migration[7.2]
  def up
    remove_column :failures, :manny_id
    drop_table :manny_synches
  end
end
