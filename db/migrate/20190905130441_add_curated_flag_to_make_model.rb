class AddCuratedFlagToMakeModel < ActiveRecord::Migration[5.1]
  def change
    add_column :make_models, :curated, :boolean, null:false, default: false
  end
end
