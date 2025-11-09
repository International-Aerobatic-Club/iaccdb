class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.integer :sequence, null: false
      t.string :category, limit: 16, null: false
      t.string :aircat, limit: 1, null: false
      t.string :name, limit: 32, null: false

      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end
