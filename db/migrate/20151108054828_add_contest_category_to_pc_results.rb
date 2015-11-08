class AddContestCategoryToPcResults < ActiveRecord::Migration
  def change
    add_column :pc_results, :contest_id, :integer
    add_index :pc_results, :contest_id
    add_column :pc_results, :category_id, :integer
    add_index :pc_results, :category_id
  end
end
