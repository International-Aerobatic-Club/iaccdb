# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111221193516) do

  create_table "c_results", :force => true do |t|
    t.integer  "contest_id"
    t.string   "category"
    t.boolean  "need_compute",              :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "aircat",       :limit => 1, :default => "P"
  end

  add_index "c_results", ["category", "aircat"], :name => "c_contest_category"

  create_table "contests", :force => true do |t|
    t.string   "name",       :limit => 48
    t.string   "city",       :limit => 24
    t.string   "state",      :limit => 2
    t.date     "start"
    t.integer  "chapter"
    t.string   "director",   :limit => 48
    t.string   "region",     :limit => 16
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "f_results", :force => true do |t|
    t.integer  "flight_id"
    t.boolean  "need_compute", :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "c_result_id"
  end

  create_table "flights", :force => true do |t|
    t.integer  "contest_id",               :null => false
    t.string   "category",   :limit => 16, :null => false
    t.string   "name",       :limit => 16, :null => false
    t.integer  "sequence",                 :null => false
    t.integer  "chief_id"
    t.integer  "assist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "aircat",     :limit => 1
  end

  create_table "jc_results", :force => true do |t|
    t.integer  "c_result_id",                                      :null => false
    t.integer  "judge_id",                                         :null => false
    t.integer  "pilot_count"
    t.integer  "sigma_d2"
    t.integer  "sigma_pj"
    t.integer  "sigma_p2"
    t.integer  "sigma_j2"
    t.decimal  "sigma_ri_delta",    :precision => 11, :scale => 5
    t.integer  "con"
    t.integer  "dis"
    t.integer  "minority_zero_ct"
    t.integer  "minority_grade_ct"
    t.boolean  "need_compute"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jf_results", :force => true do |t|
    t.integer  "f_result_id"
    t.integer  "judge_id"
    t.integer  "pilot_count"
    t.integer  "sigma_d2"
    t.integer  "sigma_pj"
    t.integer  "sigma_p2"
    t.integer  "sigma_j2"
    t.decimal  "sigma_ri_delta",    :precision => 10, :scale => 5
    t.integer  "con"
    t.integer  "dis"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "minority_zero_ct",                                 :default => 0
    t.integer  "minority_grade_ct",                                :default => 0
    t.integer  "jc_result_id"
  end

  create_table "judges", :force => true do |t|
    t.integer  "judge_id"
    t.integer  "assist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manny_synches", :force => true do |t|
    t.integer  "contest_id"
    t.integer  "manny_number"
    t.datetime "synch_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", :force => true do |t|
    t.integer  "iac_id"
    t.string   "given_name",  :limit => 40
    t.string   "family_name", :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pc_results", :force => true do |t|
    t.integer  "pilot_id",                                                       :null => false
    t.decimal  "category_value", :precision => 8, :scale => 2
    t.integer  "category_rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "need_compute",                                 :default => true
    t.integer  "c_result_id"
  end

  create_table "pf_results", :force => true do |t|
    t.integer  "pilot_flight_id",                                                  :null => false
    t.decimal  "flight_value",     :precision => 7, :scale => 2
    t.decimal  "adj_flight_value", :precision => 7, :scale => 2
    t.integer  "flight_rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "figure_results"
    t.integer  "adj_flight_rank"
    t.boolean  "need_compute",                                   :default => true
    t.integer  "pc_result_id"
    t.integer  "f_result_id"
  end

  create_table "pfj_results", :force => true do |t|
    t.integer  "pilot_flight_id",                   :null => false
    t.integer  "judge_id",                          :null => false
    t.string   "computed_values"
    t.string   "computed_ranks"
    t.integer  "flight_value"
    t.integer  "flight_rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "graded_values"
    t.string   "graded_ranks"
    t.boolean  "need_compute",    :default => true
  end

  create_table "pilot_flights", :force => true do |t|
    t.integer  "pilot_id"
    t.integer  "flight_id"
    t.integer  "sequence_id"
    t.integer  "aircraft_id"
    t.string   "chapter",       :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "penalty_total",              :default => 0
  end

  create_table "scores", :force => true do |t|
    t.integer  "pilot_flight_id"
    t.integer  "judge_id"
    t.string   "values"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sequences", :force => true do |t|
    t.integer  "figure_count"
    t.integer  "total_k"
    t.integer  "mod_3_total"
    t.string   "k_values"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sequences", ["figure_count", "total_k", "mod_3_total"], :name => "by_attrs"

end
