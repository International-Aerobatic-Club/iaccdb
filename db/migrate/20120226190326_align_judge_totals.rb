class AlignJudgeTotals < ActiveRecord::Migration
  def self.up
    change_table :jf_results do |t|
      t.integer "total_k"
      t.integer "figure_count"
      t.integer "flight_count"
    end
    change_table :jc_results do |t|
      t.integer "total_k"
      t.integer "figure_count"
      t.integer "flight_count"
      t.remove "need_compute"
    end
    change_table :jy_results do |t|
      t.integer "total_k"
      t.integer "figure_count"
      t.remove "grade_count"
      t.remove "avgK"
      t.remove "avgFlightSize"
    end
  end

  def self.down
    change_table :jf_results do |t|
      t.remove "total_k"
      t.remove "figure_count"
      t.remove "flight_count"
    end
    change_table :jc_results do |t|
      t.remove "total_k"
      t.remove "figure_count"
      t.remove "flight_count"
      t.boolean "need_compute"
    end
    change_table :jy_results do |t|
      t.remove "total_k"
      t.remove "figure_count"
      t.integer "grade_count"
      t.decimal "avgK", :precision => 5, :scale => 2
      t.decimal "avgFlightSize", :precision => 5, :scale => 2
    end
  end
end
