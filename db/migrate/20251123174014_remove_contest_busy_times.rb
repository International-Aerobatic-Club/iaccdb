class RemoveContestBusyTimes < ActiveRecord::Migration[8.1]
  def change
    remove_column :contests, :busy_start, type: :date
    remove_column :contests, :busy_end, type: :date
  end
end
