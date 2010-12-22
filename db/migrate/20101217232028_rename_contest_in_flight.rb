class RenameContestInFlight < ActiveRecord::Migration
  def self.up
    rename_column :flights, :contest, :contest_id
    rename_column :flights, :chief, :chief_id
    rename_column :flights, :assist, :assist_id
  end

  def self.down
    rename_column :flights, :contest_id, :contest
    rename_column :flights, :chief_id, :chief
    rename_column :flights, :assist_id, :assist
  end
end
