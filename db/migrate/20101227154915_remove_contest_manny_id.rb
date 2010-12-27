class RemoveContestMannyId < ActiveRecord::Migration
  def self.up
    remove_column :contests, :manny_id
  end

  def self.down
    add_column :contests, :manny_id, :integer
  end
end
