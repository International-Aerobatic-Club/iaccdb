class RemoveContestFieldLengthLimits < ActiveRecord::Migration[8.1]

  def change
    change_column :contests, :name, :string, :limit => nil
    change_column :contests, :city, :string, :limit => nil
    change_column :contests, :state, :string, :limit => nil
    change_column :contests, :director, :string, :limit => nil
    change_column :contests, :region, :string, :limit => nil
  end

  def down
    raise StandardError, 'Sorry, this is a one-way migration'
  end

end
