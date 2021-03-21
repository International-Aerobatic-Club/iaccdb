class ChangeIdsToBigint < ActiveRecord::Migration[5.1]

  def change

    # First we must change all the foreign keys
    change_column :airplanes, :make_model_id, :bigint
    remove_foreign_key :categories_flights, :flights
    remove_foreign_key :categories_flights, :categories
    change_column :categories_flights, :flight_id, :bigint
    change_column :categories_flights, :category_id, :bigint
    change_column :data_posts, :contest_id, :bigint
    change_column :failures, :contest_id, :bigint
    change_column :failures, :manny_id, :bigint
    change_column :failures, :data_post_id, :bigint
    change_column :flights, :chief_id, :bigint
    change_column :flights, :assist_id, :bigint
    change_column :jc_results, :contest_id, :bigint
    change_column :jc_results, :category_id, :bigint
    change_column :jf_results, :judge_id, :bigint
    change_column :jf_results, :flight_id, :bigint
    change_column :judges, :judge_id, :bigint
    change_column :judges, :assist_id, :bigint
    change_column :jy_results, :judge_id, :bigint
    change_column :jy_results, :category_id, :bigint
    change_column :manny_synches, :contest_id, :bigint
    change_column :pc_results, :contest_id, :bigint
    change_column :pc_results, :category_id, :bigint
    change_column :pilot_flights, :pilot_id, :bigint
    change_column :pilot_flights, :flight_id, :bigint
    change_column :pilot_flights, :sequence_id, :bigint
    change_column :pilot_flights, :airplane_id, :bigint
    change_column :region_contests, :pc_result_id, :bigint
    change_column :region_contests, :regional_pilot_id, :bigint
    change_column :regional_pilots, :pilot_id, :bigint
    change_column :regional_pilots, :category_id, :bigint
    change_column :result_accums, :result_id, :bigint
    change_column :result_accums, :pc_result_id, :bigint
    change_column :result_members, :member_id, :bigint
    change_column :result_members, :result_id, :bigint
    change_column :results, :category_id, :bigint
    change_column :results, :pilot_id, :bigint
    change_column :scores, :pilot_flight_id, :bigint
    change_column :scores, :judge_id, :bigint
    remove_foreign_key "synthetic_categories", "categories"
    remove_foreign_key "synthetic_categories", "contests"
    change_column :synthetic_categories, :contest_id, :bigint
    change_column :synthetic_categories, :regular_category_id, :bigint

    # Now we can change the table IDs
    change_column :airplanes, :id, :bigint
    change_column :categories, :id, :bigint
    change_column :contests, :id, :bigint
    change_column :data_posts, :id, :bigint
    change_column :failures, :id, :bigint
    change_column :flights, :id, :bigint
    change_column :jc_results, :id, :bigint
    change_column :jf_results, :id, :bigint
    change_column :judges, :id, :bigint
    change_column :jy_results, :id, :bigint
    change_column :make_models, :id, :bigint
    change_column :members, :id, :bigint
    change_column :pc_results, :id, :bigint
    change_column :pf_results, :id, :bigint
    change_column :pfj_results, :id, :bigint
    change_column :pilot_flights, :id, :bigint
    change_column :region_contests, :id, :bigint
    change_column :regional_pilots, :id, :bigint
    change_column :results, :id, :bigint
    change_column :result_accums, :id, :bigint
    change_column :result_members, :id, :bigint
    change_column :scores, :id, :bigint
    change_column :sequences, :id, :bigint
    change_column :synthetic_categories, :id, :bigint

    # Now put the foreign keys back
    add_foreign_key "categories_flights", "categories", on_delete: :cascade
    add_foreign_key "categories_flights", "flights", on_delete: :cascade
    add_foreign_key "synthetic_categories", "categories", column: "regular_category_id", on_update: :cascade, on_delete: :cascade
    add_foreign_key "synthetic_categories", "contests", on_delete: :cascade

  end

end
