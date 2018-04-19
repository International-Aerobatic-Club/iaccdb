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

ActiveRecord::Schema.define(version: 20180124140421) do

  create_table "airplanes", force: :cascade do |t|
    t.string   "make",       limit: 255
    t.string   "model",      limit: 255
    t.string   "reg",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "model_id",   limit: 4
  end

  add_index "airplanes", ["id"], name: "index_airplanes_on_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.integer  "sequence",   limit: 4,  null: false
    t.string   "category",   limit: 16, null: false
    t.string   "aircat",     limit: 1,  null: false
    t.string   "name",       limit: 32, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["id"], name: "index_categories_on_id", using: :btree

  create_table "contests", force: :cascade do |t|
    t.string   "name",       limit: 48
    t.string   "city",       limit: 24
    t.string   "state",      limit: 2
    t.date     "start"
    t.integer  "chapter",    limit: 4
    t.string   "director",   limit: 48
    t.string   "region",     limit: 16
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contests", ["id"], name: "index_contests_on_id", using: :btree

  create_table "data_posts", force: :cascade do |t|
    t.integer  "contest_id",        limit: 4
    t.boolean  "is_integrated",                 default: false
    t.boolean  "has_error",                     default: false
    t.string   "error_description", limit: 255
    t.boolean  "is_obsolete",                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "data_posts", ["contest_id"], name: "index_data_posts_on_contest_id", using: :btree
  add_index "data_posts", ["id"], name: "index_data_posts_on_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "failures", force: :cascade do |t|
    t.string   "step",         limit: 16
    t.integer  "contest_id",   limit: 4
    t.integer  "manny_id",     limit: 4
    t.text     "description",  limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "data_post_id", limit: 4
  end

  add_index "failures", ["contest_id"], name: "index_failures_on_contest_id", using: :btree
  add_index "failures", ["data_post_id"], name: "index_failures_on_data_post_id", using: :btree
  add_index "failures", ["id"], name: "index_failures_on_id", using: :btree
  add_index "failures", ["manny_id"], name: "index_failures_on_manny_id", using: :btree

  create_table "flights", force: :cascade do |t|
    t.integer  "contest_id",  limit: 4,  null: false
    t.string   "name",        limit: 16, null: false
    t.integer  "sequence",    limit: 4,  null: false
    t.integer  "chief_id",    limit: 4
    t.integer  "assist_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id", limit: 4
  end

  add_index "flights", ["assist_id"], name: "index_flights_on_assist_id", using: :btree
  add_index "flights", ["category_id"], name: "index_flights_on_category_id", using: :btree
  add_index "flights", ["chief_id"], name: "index_flights_on_chief_id", using: :btree
  add_index "flights", ["contest_id"], name: "index_flights_on_contest_id", using: :btree
  add_index "flights", ["id"], name: "index_flights_on_id", using: :btree

  create_table "jc_results", force: :cascade do |t|
    t.integer  "judge_id",          limit: 4,                          null: false
    t.integer  "pilot_count",       limit: 4
    t.decimal  "sigma_ri_delta",              precision: 11, scale: 5
    t.integer  "con",               limit: 4
    t.integer  "dis",               limit: 4
    t.integer  "minority_zero_ct",  limit: 4
    t.integer  "minority_grade_ct", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pair_count",        limit: 4
    t.integer  "ftsdx2",            limit: 4
    t.integer  "ftsdxdy",           limit: 4
    t.integer  "ftsdy2",            limit: 4
    t.integer  "sigma_d2",          limit: 4
    t.integer  "total_k",           limit: 4
    t.integer  "figure_count",      limit: 4
    t.integer  "flight_count",      limit: 4
    t.decimal  "ri_total",                    precision: 11, scale: 5
    t.integer  "contest_id",        limit: 4
    t.integer  "category_id",       limit: 4
  end

  add_index "jc_results", ["category_id"], name: "index_jc_results_on_category_id", using: :btree
  add_index "jc_results", ["contest_id"], name: "index_jc_results_on_contest_id", using: :btree
  add_index "jc_results", ["id"], name: "index_jc_results_on_id", using: :btree
  add_index "jc_results", ["judge_id"], name: "index_jc_results_on_judge_id", using: :btree

  create_table "jf_results", force: :cascade do |t|
    t.integer  "judge_id",          limit: 4
    t.integer  "pilot_count",       limit: 4
    t.decimal  "sigma_ri_delta",              precision: 10, scale: 5
    t.integer  "con",               limit: 4
    t.integer  "dis",               limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "minority_zero_ct",  limit: 4,                          default: 0
    t.integer  "minority_grade_ct", limit: 4,                          default: 0
    t.integer  "ftsdx2",            limit: 4
    t.integer  "ftsdxdy",           limit: 4
    t.integer  "ftsdy2",            limit: 4
    t.integer  "sigma_d2",          limit: 4
    t.integer  "pair_count",        limit: 4
    t.integer  "total_k",           limit: 4
    t.integer  "figure_count",      limit: 4
    t.integer  "flight_count",      limit: 4
    t.decimal  "ri_total",                    precision: 10, scale: 5
    t.integer  "flight_id",         limit: 4
  end

  add_index "jf_results", ["flight_id"], name: "index_jf_results_on_flight_id", using: :btree
  add_index "jf_results", ["id"], name: "index_jf_results_on_id", using: :btree
  add_index "jf_results", ["judge_id"], name: "index_jf_results_on_judge_id", using: :btree

  create_table "judges", force: :cascade do |t|
    t.integer  "judge_id",   limit: 4
    t.integer  "assist_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "judges", ["assist_id"], name: "index_judges_on_assist_id", using: :btree
  add_index "judges", ["id"], name: "index_judges_on_id", using: :btree
  add_index "judges", ["judge_id"], name: "index_judges_on_judge_id", using: :btree

  create_table "jy_results", force: :cascade do |t|
    t.integer  "judge_id",          limit: 4
    t.integer  "category_id",       limit: 4
    t.integer  "year",              limit: 4
    t.integer  "pilot_count",       limit: 4
    t.integer  "ftsdxdy",           limit: 4
    t.integer  "ftsdx2",            limit: 4
    t.integer  "ftsdy2",            limit: 4
    t.integer  "con",               limit: 4
    t.integer  "dis",               limit: 4
    t.integer  "pair_count",        limit: 4
    t.integer  "flight_count",      limit: 4
    t.decimal  "sigma_ri_delta",              precision: 12, scale: 5
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sigma_d2",          limit: 4
    t.integer  "minority_grade_ct", limit: 4
    t.integer  "minority_zero_ct",  limit: 4
    t.integer  "total_k",           limit: 4
    t.integer  "figure_count",      limit: 4
    t.decimal  "ri_total",                    precision: 12, scale: 5
  end

  add_index "jy_results", ["category_id"], name: "index_jy_results_on_category_id", using: :btree
  add_index "jy_results", ["id"], name: "index_jy_results_on_id", using: :btree
  add_index "jy_results", ["judge_id"], name: "index_jy_results_on_judge_id", using: :btree

  create_table "manny_synches", force: :cascade do |t|
    t.integer  "contest_id",   limit: 4
    t.integer  "manny_number", limit: 4
    t.datetime "synch_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "manny_synches", ["contest_id"], name: "index_manny_synches_on_contest_id", using: :btree

  create_table "members", force: :cascade do |t|
    t.integer  "iac_id",      limit: 4
    t.string   "given_name",  limit: 40
    t.string   "family_name", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "members", ["iac_id"], name: "index_members_on_iac_id", using: :btree
  add_index "members", ["id"], name: "index_members_on_id", using: :btree

  create_table "models", force: :cascade do |t|
    t.string  "make",             limit: 255
    t.string  "model",            limit: 255
    t.integer "empty_weight_lbs", limit: 2
    t.integer "max_weight_lbs",   limit: 2
    t.integer "horsepower",       limit: 2
    t.integer "seats",            limit: 1
    t.integer "wings",            limit: 1
  end

  create_table "pc_results", force: :cascade do |t|
    t.integer  "pilot_id",        limit: 4,                                         null: false
    t.decimal  "category_value",            precision: 8, scale: 2
    t.integer  "category_rank",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "need_compute",                                      default: true
    t.boolean  "star_qualifying",                                   default: false
    t.integer  "total_possible",  limit: 4
    t.integer  "contest_id",      limit: 4
    t.integer  "category_id",     limit: 4
    t.boolean  "hors_concours",                                     default: false, null: false
  end

  add_index "pc_results", ["category_id"], name: "index_pc_results_on_category_id", using: :btree
  add_index "pc_results", ["contest_id"], name: "index_pc_results_on_contest_id", using: :btree
  add_index "pc_results", ["id"], name: "index_pc_results_on_id", using: :btree
  add_index "pc_results", ["pilot_id"], name: "index_pc_results_on_pilot_id", using: :btree

  create_table "pf_results", force: :cascade do |t|
    t.integer  "pilot_flight_id",  limit: 4,                                          null: false
    t.decimal  "flight_value",                 precision: 7, scale: 2
    t.decimal  "adj_flight_value",             precision: 7, scale: 2
    t.integer  "flight_rank",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "figure_results",   limit: 255
    t.integer  "adj_flight_rank",  limit: 4
    t.boolean  "need_compute",                                         default: true
    t.string   "figure_ranks",     limit: 255
    t.integer  "total_possible",   limit: 4
  end

  add_index "pf_results", ["id"], name: "index_pf_results_on_id", using: :btree
  add_index "pf_results", ["pilot_flight_id"], name: "index_pf_results_on_pilot_flight_id", using: :btree

  create_table "pfj_results", force: :cascade do |t|
    t.integer  "pilot_flight_id", limit: 4,                  null: false
    t.integer  "judge_id",        limit: 4,                  null: false
    t.string   "computed_values", limit: 255
    t.string   "computed_ranks",  limit: 255
    t.integer  "flight_value",    limit: 4
    t.integer  "flight_rank",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "graded_values",   limit: 255
    t.string   "graded_ranks",    limit: 255
    t.boolean  "need_compute",                default: true
  end

  add_index "pfj_results", ["id"], name: "index_pfj_results_on_id", using: :btree
  add_index "pfj_results", ["judge_id"], name: "index_pfj_results_on_judge_id", using: :btree
  add_index "pfj_results", ["pilot_flight_id"], name: "index_pfj_results_on_pilot_flight_id", using: :btree

  create_table "pilot_flights", force: :cascade do |t|
    t.integer  "pilot_id",      limit: 4
    t.integer  "flight_id",     limit: 4
    t.integer  "sequence_id",   limit: 4
    t.integer  "airplane_id",   limit: 4
    t.string   "chapter",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "penalty_total", limit: 4, default: 0
    t.boolean  "hors_concours",           default: false, null: false
  end

  add_index "pilot_flights", ["airplane_id"], name: "index_pilot_flights_on_airplane_id", using: :btree
  add_index "pilot_flights", ["flight_id"], name: "index_pilot_flights_on_flight_id", using: :btree
  add_index "pilot_flights", ["id"], name: "index_pilot_flights_on_id", using: :btree
  add_index "pilot_flights", ["pilot_id"], name: "index_pilot_flights_on_pilot_id", using: :btree
  add_index "pilot_flights", ["sequence_id"], name: "index_pilot_flights_on_sequence_id", using: :btree

  create_table "region_contests", force: :cascade do |t|
    t.integer  "pc_result_id",      limit: 4
    t.integer  "regional_pilot_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "region_contests", ["id"], name: "index_region_contests_on_id", using: :btree
  add_index "region_contests", ["pc_result_id"], name: "index_region_contests_on_pc_result_id", using: :btree
  add_index "region_contests", ["regional_pilot_id"], name: "index_region_contests_on_regional_pilot_id", using: :btree

  create_table "regional_pilots", force: :cascade do |t|
    t.integer  "pilot_id",    limit: 4
    t.string   "region",      limit: 16,                                         null: false
    t.integer  "year",        limit: 4
    t.decimal  "percentage",             precision: 5, scale: 2
    t.boolean  "qualified",                                      default: false
    t.integer  "rank",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id", limit: 4
  end

  add_index "regional_pilots", ["category_id"], name: "index_regional_pilots_on_category_id", using: :btree
  add_index "regional_pilots", ["id"], name: "index_regional_pilots_on_id", using: :btree
  add_index "regional_pilots", ["pilot_id"], name: "index_regional_pilots_on_pilot_id", using: :btree

  create_table "result_accums", force: :cascade do |t|
    t.integer  "result_id",    limit: 4
    t.integer  "pc_result_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "result_accums", ["pc_result_id"], name: "index_result_accums_on_pc_result_id", using: :btree
  add_index "result_accums", ["result_id", "pc_result_id"], name: "index_result_accums_on_result_id_and_pc_result_id", unique: true, using: :btree
  add_index "result_accums", ["result_id"], name: "index_result_accums_on_result_id", using: :btree

  create_table "result_members", force: :cascade do |t|
    t.integer  "member_id",  limit: 4
    t.integer  "result_id",  limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "result_members", ["member_id", "result_id"], name: "index_result_members_on_member_id_and_result_id", unique: true, using: :btree
  add_index "result_members", ["member_id"], name: "index_result_members_on_member_id", using: :btree
  add_index "result_members", ["result_id"], name: "index_result_members_on_result_id", using: :btree

  create_table "results", force: :cascade do |t|
    t.string   "type",            limit: 255
    t.integer  "year",            limit: 4
    t.integer  "category_id",     limit: 4
    t.integer  "pilot_id",        limit: 4
    t.string   "region",          limit: 255
    t.string   "name",            limit: 255
    t.boolean  "qualified"
    t.integer  "rank",            limit: 4
    t.decimal  "points",                      precision: 9, scale: 2
    t.integer  "points_possible", limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "results", ["category_id"], name: "index_results_on_category_id", using: :btree
  add_index "results", ["id"], name: "index_results_on_id", using: :btree
  add_index "results", ["pilot_id"], name: "index_results_on_pilot_id", using: :btree

  create_table "scores", force: :cascade do |t|
    t.integer  "pilot_flight_id", limit: 4
    t.integer  "judge_id",        limit: 4
    t.string   "values",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scores", ["id"], name: "index_scores_on_id", using: :btree
  add_index "scores", ["judge_id"], name: "index_scores_on_judge_id", using: :btree
  add_index "scores", ["pilot_flight_id"], name: "index_scores_on_pilot_flight_id", using: :btree

  create_table "sequences", force: :cascade do |t|
    t.integer  "figure_count", limit: 4
    t.integer  "total_k",      limit: 4
    t.integer  "mod_3_total",  limit: 4
    t.string   "k_values",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sequences", ["figure_count", "total_k", "mod_3_total"], name: "by_attrs", using: :btree
  add_index "sequences", ["id"], name: "index_sequences_on_id", using: :btree

  create_table "writers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "writers", ["id"], name: "index_writers_on_id", using: :btree

end
