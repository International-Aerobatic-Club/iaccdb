class AddAircatToCAndPcResultsIndex < ActiveRecord::Migration
  def self.up
    add_column(:c_results, :aircat, :string, limit: 1, default: 'P')
    add_column(:pc_results, :aircat, :string, limit: 1, default: 'P')
    remove_index(:c_results, name: :c_contest_category)
    remove_index(:pc_results, name: :pc_contest_category)
    add_index(:c_results, [:category, :aircat], name: :c_contest_category)
    add_index(:pc_results, [:category, :aircat], name: :pc_contest_category)
  end

  def self.down
    remove_column(:c_results, :aircat)
    remove_column(:pc_results, :aircat)
    remove_index(:c_results, name: :c_contest_category)
    remove_index(:pc_results, name: :pc_contest_category)
    add_index(:c_results, [:contest, :category], name: :c_contest_category)
    add_index(:pc_results, [:contest, :category], name: :pc_contest_category)
  end
end
