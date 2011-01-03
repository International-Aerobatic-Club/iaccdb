class RemoveFlightNonNullConstraints < ActiveRecord::Migration
  def self.up
    change_column :flights, :chief_id, :integer, :null => true
    change_column :flights, :assist_id, :integer, :null => true
  end

  def self.down
    change_column :flights, :chief_id, :integer, :null => false
    change_column :flights, :assist_id, :integer, :null => false
  end
end
