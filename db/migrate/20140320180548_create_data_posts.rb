class CreateDataPosts < ActiveRecord::Migration
  def self.up
    create_table :data_posts do |t|
      t.integer :contest_id
      t.text :data
      t.boolean :is_integrated, :default => false
      t.boolean :has_error, :default => false
      t.string :error_description
      t.boolean :is_obsolete, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :data_posts
  end
end
