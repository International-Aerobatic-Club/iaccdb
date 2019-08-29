class MakeModelKeyLength < ActiveRecord::Migration[5.1]
  reversible do |dir|
    dir.up do
      change_column :make_models, :make, :string, limit: 80
      change_column :make_models, :model, :string, limit: 80
    end
    dir.down do
      change_column :make_models, :make, :string
      change_column :make_models, :model, :string
    end
  end
end
