# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_22_203047) do
  create_table "airplanes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.bigint "make_model_id"
    t.string "reg"
    t.datetime "updated_at", precision: nil
    t.index ["id"], name: "index_airplanes_on_id"
  end

  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "aircat", limit: 1, null: false
    t.string "category", limit: 16, null: false
    t.datetime "created_at", precision: nil
    t.string "name", limit: 48, null: false
    t.integer "sequence", null: false
    t.boolean "synthetic", default: false, null: false
    t.datetime "updated_at", precision: nil
    t.index ["category", "aircat", "name"], name: "index_categories_on_category_and_aircat_and_name", unique: true
    t.index ["id"], name: "index_categories_on_id"
  end

  create_table "categories_flights", id: false, charset: "latin1", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "flight_id", null: false
    t.index ["category_id", "flight_id"], name: "index_categories_flights_on_category_id_and_flight_id", unique: true
    t.index ["category_id"], name: "index_categories_flights_on_category_id"
    t.index ["flight_id"], name: "index_categories_flights_on_flight_id"
  end

  create_table "contests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.date "busy_end"
    t.date "busy_start"
    t.integer "chapter"
    t.string "city"
    t.datetime "created_at", precision: nil
    t.string "director"
    t.string "name"
    t.string "region"
    t.date "start"
    t.string "state"
    t.datetime "updated_at", precision: nil
    t.index ["id"], name: "index_contests_on_id"
  end

  create_table "data_posts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "contest_id"
    t.datetime "created_at", precision: nil
    t.string "error_description"
    t.boolean "has_error", default: false
    t.boolean "is_integrated", default: false
    t.boolean "is_obsolete", default: false
    t.datetime "updated_at", precision: nil
    t.index ["contest_id"], name: "index_data_posts_on_contest_id"
    t.index ["id"], name: "index_data_posts_on_id"
  end

  create_table "delayed_jobs", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "attempts", default: 0
    t.datetime "created_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.text "handler", size: :medium
    t.text "last_error", size: :medium
    t.datetime "locked_at", precision: nil
    t.string "locked_by"
    t.integer "priority", default: 0
    t.string "queue"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "failures", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "contest_id"
    t.datetime "created_at", precision: nil
    t.bigint "data_post_id"
    t.text "description", size: :medium
    t.string "step", limit: 16
    t.datetime "updated_at", precision: nil
    t.index ["contest_id"], name: "index_failures_on_contest_id"
    t.index ["data_post_id"], name: "index_failures_on_data_post_id"
    t.index ["id"], name: "index_failures_on_id"
  end

  create_table "flights", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "assist_id"
    t.bigint "chief_id"
    t.integer "contest_id", null: false
    t.datetime "created_at", precision: nil
    t.string "name", limit: 16, null: false
    t.integer "obsolete_category_reference"
    t.integer "sequence", null: false
    t.datetime "updated_at", precision: nil
    t.index ["assist_id"], name: "index_flights_on_assist_id"
    t.index ["chief_id"], name: "index_flights_on_chief_id"
    t.index ["contest_id"], name: "index_flights_on_contest_id"
    t.index ["id"], name: "index_flights_on_id"
    t.index ["obsolete_category_reference"], name: "index_flights_on_obsolete_category_reference"
  end

  create_table "free_program_ks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "category_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "max_k"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "year"
    t.index ["category_id"], name: "index_free_program_ks_on_category_id"
  end

  create_table "jc_results", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "category_id"
    t.integer "con"
    t.bigint "contest_id"
    t.datetime "created_at", precision: nil
    t.integer "dis"
    t.integer "figure_count"
    t.integer "flight_count"
    t.integer "ftsdx2"
    t.integer "ftsdxdy"
    t.integer "ftsdy2"
    t.integer "judge_id", null: false
    t.integer "minority_grade_ct"
    t.integer "minority_zero_ct"
    t.integer "pair_count"
    t.integer "pilot_count"
    t.decimal "ri_total", precision: 11, scale: 5
    t.integer "sigma_d2"
    t.decimal "sigma_ri_delta", precision: 11, scale: 5
    t.integer "total_k"
    t.datetime "updated_at", precision: nil
    t.index ["category_id"], name: "index_jc_results_on_category_id"
    t.index ["contest_id"], name: "index_jc_results_on_contest_id"
    t.index ["id"], name: "index_jc_results_on_id"
    t.index ["judge_id"], name: "index_jc_results_on_judge_id"
  end

  create_table "jf_results", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "con"
    t.datetime "created_at", precision: nil
    t.integer "dis"
    t.integer "figure_count"
    t.integer "flight_count"
    t.bigint "flight_id"
    t.integer "ftsdx2"
    t.integer "ftsdxdy"
    t.integer "ftsdy2"
    t.bigint "judge_id"
    t.integer "minority_grade_ct", default: 0
    t.integer "minority_zero_ct", default: 0
    t.integer "pair_count"
    t.integer "pilot_count"
    t.decimal "ri_total", precision: 10, scale: 5
    t.integer "sigma_d2"
    t.decimal "sigma_ri_delta", precision: 10, scale: 5
    t.integer "total_k"
    t.datetime "updated_at", precision: nil
    t.index ["flight_id"], name: "index_jf_results_on_flight_id"
    t.index ["id"], name: "index_jf_results_on_id"
    t.index ["judge_id"], name: "index_jf_results_on_judge_id"
  end

  create_table "judges", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "assist_id"
    t.datetime "created_at", precision: nil
    t.bigint "judge_id"
    t.datetime "updated_at", precision: nil
    t.index ["assist_id"], name: "index_judges_on_assist_id"
    t.index ["id"], name: "index_judges_on_id"
    t.index ["judge_id"], name: "index_judges_on_judge_id"
  end

  create_table "jy_results", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "category_id"
    t.integer "con"
    t.datetime "created_at", precision: nil
    t.integer "dis"
    t.integer "figure_count"
    t.integer "flight_count"
    t.integer "ftsdx2"
    t.integer "ftsdxdy"
    t.integer "ftsdy2"
    t.bigint "judge_id"
    t.integer "minority_grade_ct"
    t.integer "minority_zero_ct"
    t.integer "pair_count"
    t.integer "pilot_count"
    t.decimal "ri_total", precision: 12, scale: 5
    t.integer "sigma_d2"
    t.decimal "sigma_ri_delta", precision: 12, scale: 5
    t.integer "total_k"
    t.datetime "updated_at", precision: nil
    t.integer "year"
    t.index ["category_id"], name: "index_jy_results_on_category_id"
    t.index ["id"], name: "index_jy_results_on_id"
    t.index ["judge_id"], name: "index_jy_results_on_judge_id"
  end

  create_table "make_models", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "curated", default: false, null: false
    t.integer "empty_weight_lbs", limit: 2
    t.integer "horsepower", limit: 2
    t.string "make", limit: 80
    t.integer "max_weight_lbs", limit: 2
    t.string "model", limit: 80
    t.integer "seats", limit: 1
    t.integer "wings", limit: 1
    t.index ["id"], name: "index_make_models_on_id"
    t.index ["make", "model"], name: "index_make_models_on_make_and_model", unique: true
    t.index ["make"], name: "index_make_models_on_make"
    t.index ["model"], name: "index_make_models_on_model"
  end

  create_table "members", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "family_name", limit: 40
    t.string "given_name", limit: 40
    t.integer "iac_id"
    t.datetime "updated_at", precision: nil
    t.index ["iac_id"], name: "index_members_on_iac_id"
    t.index ["id"], name: "index_members_on_id"
  end

  create_table "pc_results", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "category_id"
    t.integer "category_rank"
    t.decimal "category_value", precision: 8, scale: 2
    t.bigint "contest_id"
    t.datetime "created_at", precision: nil
    t.integer "hors_concours", limit: 2, default: 0, null: false
    t.boolean "need_compute", default: true
    t.integer "pilot_id", null: false
    t.boolean "star_qualifying", default: false
    t.integer "total_possible"
    t.datetime "updated_at", precision: nil
    t.index ["category_id"], name: "index_pc_results_on_category_id"
    t.index ["contest_id"], name: "index_pc_results_on_contest_id"
    t.index ["id"], name: "index_pc_results_on_id"
    t.index ["pilot_id"], name: "index_pc_results_on_pilot_id"
  end

  create_table "pf_results", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "adj_flight_rank"
    t.decimal "adj_flight_value", precision: 7, scale: 2
    t.datetime "created_at", precision: nil
    t.string "figure_ranks"
    t.string "figure_results"
    t.integer "flight_rank"
    t.decimal "flight_value", precision: 7, scale: 2
    t.boolean "need_compute", default: true
    t.integer "pilot_flight_id", null: false
    t.integer "total_possible"
    t.datetime "updated_at", precision: nil
    t.index ["id"], name: "index_pf_results_on_id"
    t.index ["pilot_flight_id"], name: "index_pf_results_on_pilot_flight_id"
  end

  create_table "pfj_results", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "computed_ranks"
    t.string "computed_values"
    t.datetime "created_at", precision: nil
    t.integer "flight_rank"
    t.integer "flight_value"
    t.string "graded_ranks"
    t.string "graded_values"
    t.integer "judge_id", null: false
    t.boolean "need_compute", default: true
    t.integer "pilot_flight_id", null: false
    t.datetime "updated_at", precision: nil
    t.index ["id"], name: "index_pfj_results_on_id"
    t.index ["judge_id"], name: "index_pfj_results_on_judge_id"
    t.index ["pilot_flight_id"], name: "index_pfj_results_on_pilot_flight_id"
  end

  create_table "pilot_flights", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "airplane_id"
    t.string "chapter", limit: 8
    t.datetime "created_at", precision: nil
    t.bigint "flight_id"
    t.integer "hors_concours", limit: 2, default: 0, null: false
    t.integer "penalty_total", default: 0
    t.bigint "pilot_id"
    t.bigint "sequence_id"
    t.datetime "updated_at", precision: nil
    t.index ["airplane_id"], name: "index_pilot_flights_on_airplane_id"
    t.index ["flight_id"], name: "index_pilot_flights_on_flight_id"
    t.index ["id"], name: "index_pilot_flights_on_id"
    t.index ["pilot_id"], name: "index_pilot_flights_on_pilot_id"
    t.index ["sequence_id"], name: "index_pilot_flights_on_sequence_id"
  end

  create_table "region_contests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.bigint "pc_result_id"
    t.bigint "regional_pilot_id"
    t.datetime "updated_at", precision: nil
    t.index ["id"], name: "index_region_contests_on_id"
    t.index ["pc_result_id"], name: "index_region_contests_on_pc_result_id"
    t.index ["regional_pilot_id"], name: "index_region_contests_on_regional_pilot_id"
  end

  create_table "regional_pilots", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "category_id"
    t.datetime "created_at", precision: nil
    t.decimal "percentage", precision: 5, scale: 2
    t.bigint "pilot_id"
    t.boolean "qualified", default: false
    t.integer "rank"
    t.string "region", limit: 16, null: false
    t.datetime "updated_at", precision: nil
    t.integer "year"
    t.index ["category_id"], name: "index_regional_pilots_on_category_id"
    t.index ["id"], name: "index_regional_pilots_on_id"
    t.index ["pilot_id"], name: "index_regional_pilots_on_pilot_id"
  end

  create_table "result_accums", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.bigint "pc_result_id"
    t.bigint "result_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["pc_result_id"], name: "index_result_accums_on_pc_result_id"
    t.index ["result_id", "pc_result_id"], name: "index_result_accums_on_result_id_and_pc_result_id", unique: true
    t.index ["result_id"], name: "index_result_accums_on_result_id"
  end

  create_table "result_members", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.bigint "member_id"
    t.bigint "result_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["member_id", "result_id"], name: "index_result_members_on_member_id_and_result_id", unique: true
    t.index ["member_id"], name: "index_result_members_on_member_id"
    t.index ["result_id"], name: "index_result_members_on_result_id"
  end

  create_table "results", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "category_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.bigint "pilot_id"
    t.decimal "points", precision: 9, scale: 2
    t.integer "points_possible"
    t.boolean "qualified"
    t.integer "rank"
    t.string "region"
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "year"
    t.index ["category_id"], name: "index_results_on_category_id"
    t.index ["id"], name: "index_results_on_id"
    t.index ["pilot_id"], name: "index_results_on_pilot_id"
  end

  create_table "scores", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.bigint "judge_id"
    t.bigint "pilot_flight_id"
    t.datetime "updated_at", precision: nil
    t.string "values"
    t.index ["id"], name: "index_scores_on_id"
    t.index ["judge_id"], name: "index_scores_on_judge_id"
    t.index ["pilot_flight_id"], name: "index_scores_on_pilot_flight_id"
  end

  create_table "sequences", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "figure_count"
    t.string "k_values"
    t.integer "mod_3_total"
    t.integer "total_k"
    t.datetime "updated_at", precision: nil
    t.index ["figure_count", "total_k", "mod_3_total"], name: "by_attrs"
    t.index ["id"], name: "index_sequences_on_id"
  end

  create_table "synthetic_categories", charset: "latin1", force: :cascade do |t|
    t.bigint "contest_id"
    t.datetime "created_at", precision: nil, null: false
    t.text "regular_category_flights"
    t.bigint "regular_category_id"
    t.string "synthetic_category_description", limit: 48, null: false
    t.text "synthetic_category_flights"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["contest_id"], name: "index_synthetic_categories_on_contest_id"
    t.index ["regular_category_id"], name: "index_synthetic_categories_on_regular_category_id"
  end
end
