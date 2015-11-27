class RemoveFResultTable < ActiveRecord::Migration
  def up
    remove_index "f_results", ["c_result_id"]
    remove_index "f_results", ["flight_id"]
    remove_index "f_results", ["id"]
    drop_table "f_results"
  end
  def down
    create_table "f_results", force: true do |t|
      t.integer  "flight_id"
      t.boolean  "need_compute", default: true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "c_result_id"
    end

    add_index "f_results", ["c_result_id"], name: "index_f_results_on_c_result_id", using: :btree
    add_index "f_results", ["flight_id"], name: "index_f_results_on_flight_id", using: :btree
    add_index "f_results", ["id"], name: "index_f_results_on_id", using: :btree
  end
end
