class RenameFlightsCategoryIdColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column(:flights, :category_id, :obsolete_category_reference)
  end
end
