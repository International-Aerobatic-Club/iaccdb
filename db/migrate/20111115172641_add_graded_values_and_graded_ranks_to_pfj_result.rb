class AddGradedValuesAndGradedRanksToPfjResult < ActiveRecord::Migration
  def self.up
    change_table :pfj_results do |t|
      t.string :graded_values
      t.string :graded_ranks
    end
  end

  def self.down
    change_table :pfj_results do |t|
      t.remove_column :graded_values
      t.remove_column :graded_ranks
    end
  end
end
