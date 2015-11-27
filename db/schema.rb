# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151127182017) do

  create_table "airplanes", force: true do |t|
    t.string   "make"
    t.string   "model"
    t.string   "reg"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "airplanes", ["id"], name: "index_airplanes_on_id", using: :btree

  create_table "categories", force: true do |t|
    t.integer  "sequence",              null: false
    t.string   "category",   limit: 16, null: false
    t.string   "aircat",     limit: 1,  null: false
    t.string   "name",       limit: 32, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["id"], name: "index_categories_on_id", using: :btree

  create_table "contests", force: true do |t|
    t.string   "name",       limit: 48
    t.string   "city",       limit: 24
    t.string   "state",      limit: 2
    t.date     "start"
    t.integer  "chapter"
    t.string   "director",   limit: 48
    t.string   "region",     limit: 16
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contests", ["id"], name: "index_contests_on_id", using: :btree

  create_table "data_posts", force: true do |t|
    t.integer  "contest_id"
    t.boolean  "is_integrated",     default: false
    t.boolean  "has_error",         default: false
    t.string   "error_description"
    t.boolean  "is_obsolete",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "data_posts", ["contest_id"], name: "index_data_posts_on_contest_id", using: :btree
  add_index "data_posts", ["id"], name: "index_data_posts_on_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "failures", force: true do |t|
    t.string   "step",         limit: 16
    t.integer  "contest_id"
    t.integer  "manny_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "data_post_id"
  end

  add_index "failures", ["contest_id"], name: "index_failures_on_contest_id", using: :btree
  add_index "failures", ["data_post_id"], name: "index_failures_on_data_post_id", using: :btree
  add_index "failures", ["id"], name: "index_failures_on_id", using: :btree
  add_index "failures", ["manny_id"], name: "index_failures_on_manny_id", using: :btree

  create_table "flights", force: true do |t|
    t.integer  "contest_id",             null: false
    t.string   "name",        limit: 16, null: false
    t.integer  "sequence",               null: false
    t.integer  "chief_id"
    t.integer  "assist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
  end

  add_index "flights", ["assist_id"], name: "index_flights_on_assist_id", using: :btree
  add_index "flights", ["category_id"], name: "index_flights_on_category_id", using: :btree
  add_index "flights", ["chief_id"], name: "index_flights_on_chief_id", using: :btree
  add_index "flights", ["contest_id"], name: "index_flights_on_contest_id", using: :btree
  add_index "flights", ["id"], name: "index_flights_on_id", using: :btree

  create_table "jc_results", force: true do |t|
    t.integer  "c_result_id"
    t.integer  "judge_id",                                   null: false
    t.integer  "pilot_count"
    t.decimal  "sigma_ri_delta",    precision: 11, scale: 5
    t.integer  "con"
    t.integer  "dis"
    t.integer  "minority_zero_ct"
    t.integer  "minority_grade_ct"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pair_count"
    t.integer  "ftsdx2"
    t.integer  "ftsdxdy"
    t.integer  "ftsdy2"
    t.integer  "sigma_d2"
    t.integer  "total_k"
    t.integer  "figure_count"
    t.integer  "flight_count"
    t.decimal  "ri_total",          precision: 11, scale: 5
    t.integer  "contest_id"
    t.integer  "category_id"
  end

  add_index "jc_results", ["c_result_id"], name: "index_jc_results_on_c_result_id", using: :btree
  add_index "jc_results", ["category_id"], name: "index_jc_results_on_category_id", using: :btree
  add_index "jc_results", ["contest_id"], name: "index_jc_results_on_contest_id", using: :btree
  add_index "jc_results", ["id"], name: "index_jc_results_on_id", using: :btree
  add_index "jc_results", ["judge_id"], name: "index_jc_results_on_judge_id", using: :btree

  create_table "jf_results", force: true do |t|
    t.integer  "f_result_id"
    t.integer  "judge_id"
    t.integer  "pilot_count"
    t.decimal  "sigma_ri_delta",    precision: 10, scale: 5
    t.integer  "con"
    t.integer  "dis"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "minority_zero_ct",                           default: 0
    t.integer  "minority_grade_ct",                          default: 0
    t.integer  "jc_result_id"
    t.integer  "ftsdx2"
    t.integer  "ftsdxdy"
    t.integer  "ftsdy2"
    t.integer  "sigma_d2"
    t.integer  "pair_count"
    t.integer  "total_k"
    t.integer  "figure_count"
    t.integer  "flight_count"
    t.decimal  "ri_total",          precision: 10, scale: 5
    t.integer  "flight_id"
  end

  add_index "jf_results", ["f_result_id"], name: "index_jf_results_on_f_result_id", using: :btree
  add_index "jf_results", ["flight_id"], name: "index_jf_results_on_flight_id", using: :btree
  add_index "jf_results", ["id"], name: "index_jf_results_on_id", using: :btree
  add_index "jf_results", ["jc_result_id"], name: "index_jf_results_on_jc_result_id", using: :btree
  add_index "jf_results", ["judge_id"], name: "index_jf_results_on_judge_id", using: :btree

  create_table "judges", force: true do |t|
    t.integer  "judge_id"
    t.integer  "assist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "judges", ["assist_id"], name: "index_judges_on_assist_id", using: :btree
  add_index "judges", ["id"], name: "index_judges_on_id", using: :btree
  add_index "judges", ["judge_id"], name: "index_judges_on_judge_id", using: :btree

  create_table "jy_results", force: true do |t|
    t.integer  "judge_id"
    t.integer  "category_id"
    t.integer  "year"
    t.integer  "pilot_count"
    t.integer  "ftsdxdy"
    t.integer  "ftsdx2"
    t.integer  "ftsdy2"
    t.integer  "con"
    t.integer  "dis"
    t.integer  "pair_count"
    t.integer  "flight_count"
    t.decimal  "sigma_ri_delta",    precision: 12, scale: 5
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sigma_d2"
    t.integer  "minority_grade_ct"
    t.integer  "minority_zero_ct"
    t.integer  "total_k"
    t.integer  "figure_count"
    t.decimal  "ri_total",          precision: 12, scale: 5
  end

  add_index "jy_results", ["category_id"], name: "index_jy_results_on_category_id", using: :btree
  add_index "jy_results", ["id"], name: "index_jy_results_on_id", using: :btree
  add_index "jy_results", ["judge_id"], name: "index_jy_results_on_judge_id", using: :btree

  create_table "manny_synches", force: true do |t|
    t.integer  "contest_id"
    t.integer  "manny_number"
    t.datetime "synch_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "manny_synches", ["contest_id"], name: "index_manny_synches_on_contest_id", using: :btree

  create_table "members", force: true do |t|
    t.integer  "iac_id"
    t.string   "given_name",  limit: 40
    t.string   "family_name", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "members", ["iac_id"], name: "index_members_on_iac_id", using: :btree
  add_index "members", ["id"], name: "index_members_on_id", using: :btree

  create_table "pc_results", force: true do |t|
    t.integer  "pilot_id",                                                null: false
    t.decimal  "category_value",  precision: 8, scale: 2
    t.integer  "category_rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "need_compute",                            default: true
    t.integer  "c_result_id"
    t.boolean  "star_qualifying",                         default: false
    t.integer  "total_possible"
    t.integer  "contest_id"
    t.integer  "category_id"
  end

  add_index "pc_results", ["c_result_id"], name: "index_pc_results_on_c_result_id", using: :btree
  add_index "pc_results", ["category_id"], name: "index_pc_results_on_category_id", using: :btree
  add_index "pc_results", ["contest_id"], name: "index_pc_results_on_contest_id", using: :btree
  add_index "pc_results", ["id"], name: "index_pc_results_on_id", using: :btree
  add_index "pc_results", ["pilot_id"], name: "index_pc_results_on_pilot_id", using: :btree

  create_table "pf_results", force: true do |t|
    t.integer  "pilot_flight_id",                                         null: false
    t.decimal  "flight_value",     precision: 7, scale: 2
    t.decimal  "adj_flight_value", precision: 7, scale: 2
    t.integer  "flight_rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "figure_results"
    t.integer  "adj_flight_rank"
    t.boolean  "need_compute",                             default: true
    t.string   "figure_ranks"
    t.integer  "total_possible"
  end

  add_index "pf_results", ["id"], name: "index_pf_results_on_id", using: :btree
  add_index "pf_results", ["pilot_flight_id"], name: "index_pf_results_on_pilot_flight_id", using: :btree

  create_table "pfj_results", force: true do |t|
    t.integer  "pilot_flight_id",                null: false
    t.integer  "judge_id",                       null: false
    t.string   "computed_values"
    t.string   "computed_ranks"
    t.integer  "flight_value"
    t.integer  "flight_rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "graded_values"
    t.string   "graded_ranks"
    t.boolean  "need_compute",    default: true
  end

  add_index "pfj_results", ["id"], name: "index_pfj_results_on_id", using: :btree
  add_index "pfj_results", ["judge_id"], name: "index_pfj_results_on_judge_id", using: :btree
  add_index "pfj_results", ["pilot_flight_id"], name: "index_pfj_results_on_pilot_flight_id", using: :btree

  create_table "pilot_flights", force: true do |t|
    t.integer  "pilot_id"
    t.integer  "flight_id"
    t.integer  "sequence_id"
    t.integer  "airplane_id"
    t.string   "chapter",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "penalty_total",           default: 0
  end

  add_index "pilot_flights", ["airplane_id"], name: "index_pilot_flights_on_airplane_id", using: :btree
  add_index "pilot_flights", ["flight_id"], name: "index_pilot_flights_on_flight_id", using: :btree
  add_index "pilot_flights", ["id"], name: "index_pilot_flights_on_id", using: :btree
  add_index "pilot_flights", ["pilot_id"], name: "index_pilot_flights_on_pilot_id", using: :btree
  add_index "pilot_flights", ["sequence_id"], name: "index_pilot_flights_on_sequence_id", using: :btree

  create_table "region_contests", force: true do |t|
    t.integer  "pc_result_id"
    t.integer  "regional_pilot_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "region_contests", ["id"], name: "index_region_contests_on_id", using: :btree
  add_index "region_contests", ["pc_result_id"], name: "index_region_contests_on_pc_result_id", using: :btree
  add_index "region_contests", ["regional_pilot_id"], name: "index_region_contests_on_regional_pilot_id", using: :btree

  create_table "regional_pilots", force: true do |t|
    t.integer  "pilot_id"
    t.string   "region",      limit: 16,                                         null: false
    t.integer  "year"
    t.decimal  "percentage",             precision: 5, scale: 2
    t.boolean  "qualified",                                      default: false
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
  end

  add_index "regional_pilots", ["category_id"], name: "index_regional_pilots_on_category_id", using: :btree
  add_index "regional_pilots", ["id"], name: "index_regional_pilots_on_id", using: :btree
  add_index "regional_pilots", ["pilot_id"], name: "index_regional_pilots_on_pilot_id", using: :btree

  create_table "result_accums", force: true do |t|
    t.integer  "result_id"
    t.integer  "pc_result_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "result_accums", ["pc_result_id"], name: "index_result_accums_on_pc_result_id", using: :btree
  add_index "result_accums", ["result_id", "pc_result_id"], name: "index_result_accums_on_result_id_and_pc_result_id", unique: true, using: :btree
  add_index "result_accums", ["result_id"], name: "index_result_accums_on_result_id", using: :btree

  create_table "result_members", force: true do |t|
    t.integer  "member_id"
    t.integer  "result_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "result_members", ["member_id", "result_id"], name: "index_result_members_on_member_id_and_result_id", unique: true, using: :btree
  add_index "result_members", ["member_id"], name: "index_result_members_on_member_id", using: :btree
  add_index "result_members", ["result_id"], name: "index_result_members_on_result_id", using: :btree

  create_table "results", force: true do |t|
    t.string   "type"
    t.integer  "year"
    t.integer  "category_id"
    t.integer  "pilot_id"
    t.string   "region"
    t.string   "name"
    t.boolean  "qualified"
    t.integer  "rank"
    t.decimal  "points",          precision: 9, scale: 2
    t.integer  "points_possible"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "results", ["category_id"], name: "index_results_on_category_id", using: :btree
  add_index "results", ["id"], name: "index_results_on_id", using: :btree
  add_index "results", ["pilot_id"], name: "index_results_on_pilot_id", using: :btree

  create_table "scores", force: true do |t|
    t.integer  "pilot_flight_id"
    t.integer  "judge_id"
    t.string   "values"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scores", ["id"], name: "index_scores_on_id", using: :btree
  add_index "scores", ["judge_id"], name: "index_scores_on_judge_id", using: :btree
  add_index "scores", ["pilot_flight_id"], name: "index_scores_on_pilot_flight_id", using: :btree

  create_table "sequences", force: true do |t|
    t.integer  "figure_count"
    t.integer  "total_k"
    t.integer  "mod_3_total"
    t.string   "k_values"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sequences", ["figure_count", "total_k", "mod_3_total"], name: "by_attrs", using: :btree
  add_index "sequences", ["id"], name: "index_sequences_on_id", using: :btree

  create_table "writers", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "writers", ["id"], name: "index_writers_on_id", using: :btree

end
