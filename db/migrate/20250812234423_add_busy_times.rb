# At some contests, notably the U.S. National Championships, users refresh the results screen
# too often for the server to keep up. Which just leads to more refreshes. We addressed the problem
# in 2024 by implementing the `live_results#show` view, and it worked well. But we need to prevent
# users from using the `Contest#show` view during the busy periods.

# This migration adds a `busy_start` and `busy_end` columns to the `Contest` table.
class AddBusyTimes < ActiveRecord::Migration[5.2]
  def change
    add_column :contests, :busy_start, :date
    add_column :contests, :busy_end, :date
  end
end
