class AddDefaultNeedComputeJcResults < ActiveRecord::Migration
  def self.up
    change_column_default(:jc_results, :need_compute, true)
  end

  def self.down
  end
end
