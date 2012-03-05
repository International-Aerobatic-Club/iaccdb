class KeepRiValueForAveraging < ActiveRecord::Migration
  def self.up
    change_table :jf_results do |t|
      t.decimal "ri_total", :precision => 10, :scale => 5
    end
    change_table :jc_results do |t|
      t.decimal "ri_total", :precision => 11, :scale => 5
    end
    change_table :jy_results do |t|
      t.decimal "ri_total", :precision => 12, :scale => 5
    end
  end

  def self.down
    change_table :jf_results do |t|
      t.remove "ri_total"
    end
    change_table :jc_results do |t|
      t.remove "ri_total"
    end
    change_table :jy_results do |t|
      t.remove "ri_total"
    end
  end
end
