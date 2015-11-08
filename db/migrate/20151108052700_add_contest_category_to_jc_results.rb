class AddContestCategoryToJcResults < ActiveRecord::Migration
  def change
    add_column :jc_results, :contest_id, :integer
    add_index :jc_results, :contest_id
    add_column :jc_results, :category_id, :integer
    add_index :jc_results, :category_id
  end
end
