class IndexForeignKeys < ActiveRecord::Migration
  def change
    add_index :c_results, :contest_id
    add_index :c_results, :category_id
    add_index :data_posts, :contest_id
    add_index :f_results, :flight_id
    add_index :f_results, :c_result_id
    add_index :failures, :contest_id
    add_index :failures, :data_post_id
    add_index :failures, :manny_id
    add_index :flights, :contest_id
    add_index :flights, :category_id
    add_index :flights, :chief_id
    add_index :flights, :assist_id
    add_index :jc_results, :c_result_id
    add_index :jc_results, :judge_id
    add_index :jf_results, :f_result_id
    add_index :jf_results, :judge_id
    add_index :jf_results, :jc_result_id
    add_index :judges, :judge_id
    add_index :judges, :assist_id
    add_index :jy_results, :judge_id
    add_index :jy_results, :category_id
    add_index :manny_synches, :contest_id
    add_index :members, :iac_id
    add_index :pc_results, :pilot_id
    add_index :pc_results, :c_result_id
    add_index :pf_results, :pilot_flight_id
    add_index :pf_results, :pc_result_id
    add_index :pf_results, :f_result_id
    add_index :pfj_results, :pilot_flight_id
    add_index :pfj_results, :judge_id
    add_index :pilot_flights, :pilot_id
    add_index :pilot_flights, :flight_id
    add_index :pilot_flights, :sequence_id
    add_index :pilot_flights, :airplane_id
    add_index :region_contests, :pc_result_id
    add_index :region_contests, :regional_pilot_id
    add_index :regional_pilots, :pilot_id
    add_index :regional_pilots, :category_id
    add_index :results, :category_id
    add_index :results, :pilot_id
    add_index :scores, :pilot_flight_id
    add_index :scores, :judge_id
  end
end
