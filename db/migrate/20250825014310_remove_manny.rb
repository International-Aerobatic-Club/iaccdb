class RemoveManny < ActiveRecord::Migration[6.1]

  def up
    remove_column :failures, :manny_id, :integer
    drop_table :manny_synches
  end

  def down
    raise RuntimeError, 'Sorry, this is a one-way migration'
  end

end
