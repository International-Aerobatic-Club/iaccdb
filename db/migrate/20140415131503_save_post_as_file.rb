class SavePostAsFile < ActiveRecord::Migration
  def self.up
    remove_column :data_posts, :data
  end

  def self.down
    add_column :data_posts, :data, :text
  end
end
