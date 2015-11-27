class RemoveCResultTable < ActiveRecord::Migration
  def up
    remove_index "c_results", ["category_id"]
    remove_index "c_results", ["contest_id"]
    remove_index "c_results", ["id"]
    drop_table "c_results"
  end
  def down
    create_table "c_results", force: true do |t|
      t.integer  "contest_id"
      t.boolean  "need_compute", default: true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "category_id"
    end

    add_index "c_results", ["category_id"], name: "index_c_results_on_category_id", using: :btree
    add_index "c_results", ["contest_id"], name: "index_c_results_on_contest_id", using: :btree
    add_index "c_results", ["id"], name: "index_c_results_on_id", using: :btree
  end
end
