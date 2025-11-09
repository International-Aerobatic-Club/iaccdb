class AddDirtyMarks < ActiveRecord::Migration
  def self.up
    add_column :pfj_results, :need_compute, :boolean, default: true
    add_column :pf_results, :need_compute, :boolean, default: true
    add_column :pc_results, :need_compute, :boolean, default: true
  end

  def self.down
    remove_column :pfj_results, :need_compute
    remove_column :pf_results, :need_compute
    remove_column :pc_results, :need_compute
  end
end
