class AddPostIdToFailures < ActiveRecord::Migration
  def self.up
    change_table :failures do |t|
      t.integer :data_post_id
    end
  end

  def self.down
    remove_column :failures, :data_post_id
  end
end
