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

ActiveRecord::Schema.define(version: 20190905130441) do

  create_table "airplanes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "reg"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "make_model_id"
    t.index ["id"], name: "index_airplanes_on_id"
  end

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "sequence", null: false
    t.string "category", limit: 16, null: false
    t.string "aircat", limit: 1, null: false
    t.string "name", limit: 32, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["id"], name: "index_categories_on_id"
  end

  create_table "contests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name", limit: 48
    t.string "city", limit: 24
    t.string "state", limit: 2
    t.date "start"
    t.integer "chapter"
    t.string "director", limit: 48
    t.string "region", limit: 16
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["id"], name: "index_contests_on_id"
  end

  create_table "data_posts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "contest_id"
    t.boolean "is_integrated", default: false
    t.boolean "has_error", default: false
    t.string "error_description"
    t.boolean "is_obsolete", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["contest_id"], name: "index_data_posts_on_contest_id"
    t.index ["id"], name: "index_data_posts_on_id"
  end

  create_table "delayed_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler", limit: 16777215
    t.text "last_error", limit: 16777215
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "failures", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "step", limit: 16
    t.integer "contest_id"
    t.integer "manny_id"
    t.text "description", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_post_id"
    t.index ["contest_id"], name: "index_failures_on_contest_id"
    t.index ["data_post_id"], name: "index_failures_on_data_post_id"
    t.index ["id"], name: "index_failures_on_id"
    t.index ["manny_id"], name: "index_failures_on_manny_id"
  end

  create_table "flights", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "contest_id", null: false
    t.string "name", limit: 16, null: false
    t.integer "sequence", null: false
    t.integer "chief_id"
    t.integer "assist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "category_id"
    t.index ["assist_id"], name: "index_flights_on_assist_id"
    t.index ["category_id"], name: "index_flights_on_category_id"
    t.index ["chief_id"], name: "index_flights_on_chief_id"
    t.index ["contest_id"], name: "index_flights_on_contest_id"
    t.index ["id"], name: "index_flights_on_id"
  end

  create_table "jc_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "judge_id", null: false
    t.integer "pilot_count"
    t.decimal "sigma_ri_delta", precision: 11, scale: 5
    t.integer "con"
    t.integer "dis"
    t.integer "minority_zero_ct"
    t.integer "minority_grade_ct"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "pair_count"
    t.integer "ftsdx2"
    t.integer "ftsdxdy"
    t.integer "ftsdy2"
    t.integer "sigma_d2"
    t.integer "total_k"
    t.integer "figure_count"
    t.integer "flight_count"
    t.decimal "ri_total", precision: 11, scale: 5
    t.integer "contest_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_jc_results_on_category_id"
    t.index ["contest_id"], name: "index_jc_results_on_contest_id"
    t.index ["id"], name: "index_jc_results_on_id"
    t.index ["judge_id"], name: "index_jc_results_on_judge_id"
  end

  create_table "jf_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "judge_id"
    t.integer "pilot_count"
    t.decimal "sigma_ri_delta", precision: 10, scale: 5
    t.integer "con"
    t.integer "dis"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "minority_zero_ct", default: 0
    t.integer "minority_grade_ct", default: 0
    t.integer "ftsdx2"
    t.integer "ftsdxdy"
    t.integer "ftsdy2"
    t.integer "sigma_d2"
    t.integer "pair_count"
    t.integer "total_k"
    t.integer "figure_count"
    t.integer "flight_count"
    t.decimal "ri_total", precision: 10, scale: 5
    t.integer "flight_id"
    t.index ["flight_id"], name: "index_jf_results_on_flight_id"
    t.index ["id"], name: "index_jf_results_on_id"
    t.index ["judge_id"], name: "index_jf_results_on_judge_id"
  end

  create_table "judges", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "judge_id"
    t.integer "assist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["assist_id"], name: "index_judges_on_assist_id"
    t.index ["id"], name: "index_judges_on_id"
    t.index ["judge_id"], name: "index_judges_on_judge_id"
  end

  create_table "jy_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "judge_id"
    t.integer "category_id"
    t.integer "year"
    t.integer "pilot_count"
    t.integer "ftsdxdy"
    t.integer "ftsdx2"
    t.integer "ftsdy2"
    t.integer "con"
    t.integer "dis"
    t.integer "pair_count"
    t.integer "flight_count"
    t.decimal "sigma_ri_delta", precision: 12, scale: 5
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sigma_d2"
    t.integer "minority_grade_ct"
    t.integer "minority_zero_ct"
    t.integer "total_k"
    t.integer "figure_count"
    t.decimal "ri_total", precision: 12, scale: 5
    t.index ["category_id"], name: "index_jy_results_on_category_id"
    t.index ["id"], name: "index_jy_results_on_id"
    t.index ["judge_id"], name: "index_jy_results_on_judge_id"
  end

  create_table "make_models", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "make", limit: 80
    t.string "model", limit: 80
    t.integer "empty_weight_lbs", limit: 2
    t.integer "max_weight_lbs", limit: 2
    t.integer "horsepower", limit: 2
    t.integer "seats", limit: 1
    t.integer "wings", limit: 1
    t.boolean "curated", default: false, null: false
    t.index ["id"], name: "index_make_models_on_id"
    t.index ["make", "model"], name: "index_make_models_on_make_and_model", unique: true
    t.index ["make"], name: "index_make_models_on_make"
    t.index ["model"], name: "index_make_models_on_model"
  end

  create_table "manny_synches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "contest_id"
    t.integer "manny_number"
    t.datetime "synch_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["contest_id"], name: "index_manny_synches_on_contest_id"
  end

  create_table "members", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "iac_id"
    t.string "given_name", limit: 40
    t.string "family_name", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["iac_id"], name: "index_members_on_iac_id"
    t.index ["id"], name: "index_members_on_id"
  end

  create_table "pc_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "pilot_id", null: false
    t.decimal "category_value", precision: 8, scale: 2
    t.integer "category_rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "need_compute", default: true
    t.boolean "star_qualifying", default: false
    t.integer "total_possible"
    t.integer "contest_id"
    t.integer "category_id"
    t.integer "hors_concours", limit: 2, default: 0, null: false
    t.index ["category_id"], name: "index_pc_results_on_category_id"
    t.index ["contest_id"], name: "index_pc_results_on_contest_id"
    t.index ["id"], name: "index_pc_results_on_id"
    t.index ["pilot_id"], name: "index_pc_results_on_pilot_id"
  end

  create_table "pf_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "pilot_flight_id", null: false
    t.decimal "flight_value", precision: 7, scale: 2
    t.decimal "adj_flight_value", precision: 7, scale: 2
    t.integer "flight_rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "figure_results"
    t.integer "adj_flight_rank"
    t.boolean "need_compute", default: true
    t.string "figure_ranks"
    t.integer "total_possible"
    t.index ["id"], name: "index_pf_results_on_id"
    t.index ["pilot_flight_id"], name: "index_pf_results_on_pilot_flight_id"
  end

  create_table "pfj_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "pilot_flight_id", null: false
    t.integer "judge_id", null: false
    t.string "computed_values"
    t.string "computed_ranks"
    t.integer "flight_value"
    t.integer "flight_rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "graded_values"
    t.string "graded_ranks"
    t.boolean "need_compute", default: true
    t.index ["id"], name: "index_pfj_results_on_id"
    t.index ["judge_id"], name: "index_pfj_results_on_judge_id"
    t.index ["pilot_flight_id"], name: "index_pfj_results_on_pilot_flight_id"
  end

  create_table "pilot_flights", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "pilot_id"
    t.integer "flight_id"
    t.integer "sequence_id"
    t.integer "airplane_id"
    t.string "chapter", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "penalty_total", default: 0
    t.integer "hors_concours", limit: 2, default: 0, null: false
    t.index ["airplane_id"], name: "index_pilot_flights_on_airplane_id"
    t.index ["flight_id"], name: "index_pilot_flights_on_flight_id"
    t.index ["id"], name: "index_pilot_flights_on_id"
    t.index ["pilot_id"], name: "index_pilot_flights_on_pilot_id"
    t.index ["sequence_id"], name: "index_pilot_flights_on_sequence_id"
  end

  create_table "region_contests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "pc_result_id"
    t.integer "regional_pilot_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["id"], name: "index_region_contests_on_id"
    t.index ["pc_result_id"], name: "index_region_contests_on_pc_result_id"
    t.index ["regional_pilot_id"], name: "index_region_contests_on_regional_pilot_id"
  end

  create_table "regional_pilots", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "pilot_id"
    t.string "region", limit: 16, null: false
    t.integer "year"
    t.decimal "percentage", precision: 5, scale: 2
    t.boolean "qualified", default: false
    t.integer "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "category_id"
    t.index ["category_id"], name: "index_regional_pilots_on_category_id"
    t.index ["id"], name: "index_regional_pilots_on_id"
    t.index ["pilot_id"], name: "index_regional_pilots_on_pilot_id"
  end

  create_table "result_accums", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "result_id"
    t.integer "pc_result_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pc_result_id"], name: "index_result_accums_on_pc_result_id"
    t.index ["result_id", "pc_result_id"], name: "index_result_accums_on_result_id_and_pc_result_id", unique: true
    t.index ["result_id"], name: "index_result_accums_on_result_id"
  end

  create_table "result_members", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "member_id"
    t.integer "result_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id", "result_id"], name: "index_result_members_on_member_id_and_result_id", unique: true
    t.index ["member_id"], name: "index_result_members_on_member_id"
    t.index ["result_id"], name: "index_result_members_on_result_id"
  end

  create_table "results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "type"
    t.integer "year"
    t.integer "category_id"
    t.integer "pilot_id"
    t.string "region"
    t.string "name"
    t.boolean "qualified"
    t.integer "rank"
    t.decimal "points", precision: 9, scale: 2
    t.integer "points_possible"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_results_on_category_id"
    t.index ["id"], name: "index_results_on_id"
    t.index ["pilot_id"], name: "index_results_on_pilot_id"
  end

  create_table "scores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "pilot_flight_id"
    t.integer "judge_id"
    t.string "values"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["id"], name: "index_scores_on_id"
    t.index ["judge_id"], name: "index_scores_on_judge_id"
    t.index ["pilot_flight_id"], name: "index_scores_on_pilot_flight_id"
  end

  create_table "sequences", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "figure_count"
    t.integer "total_k"
    t.integer "mod_3_total"
    t.string "k_values"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["figure_count", "total_k", "mod_3_total"], name: "by_attrs"
    t.index ["id"], name: "index_sequences_on_id"
  end

  create_table "writers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_writers_on_id"
  end

end
