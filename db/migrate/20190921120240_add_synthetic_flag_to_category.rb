class AddSyntheticFlagToCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :categories, :synthetic, :boolean, null: false, default: false
  end
end
