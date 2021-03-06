class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.string :type
      t.integer :year
      t.integer :category_id
      t.integer :pilot_id
      t.string :region
      t.string :name
      t.boolean :qualified
      t.integer :rank
      t.decimal :points, :precision => 9, :scale => 2
      t.integer :points_possible

      t.timestamps
    end
  end
end
