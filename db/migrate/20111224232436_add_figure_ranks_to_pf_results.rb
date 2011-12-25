class AddFigureRanksToPfResults < ActiveRecord::Migration
  def self.up
    add_column :pf_results, :figure_ranks, :string
  end

  def self.down
    remove_column :pf_results, :figure_ranks
  end
end
