class FixIdAutoincrement < ActiveRecord::Migration[5.1]

  def change

    # Now we can change the table IDs
    change_column :airplanes, :id, :bigint, autoincrement: true
    change_column :categories, :id, :bigint, autoincrement: true
    change_column :contests, :id, :bigint, autoincrement: true
    change_column :data_posts, :id, :bigint, autoincrement: true
    change_column :failures, :id, :bigint, autoincrement: true
    change_column :flights, :id, :bigint, autoincrement: true
    change_column :jc_results, :id, :bigint, autoincrement: true
    change_column :jf_results, :id, :bigint, autoincrement: true
    change_column :judges, :id, :bigint, autoincrement: true
    change_column :jy_results, :id, :bigint, autoincrement: true
    change_column :make_models, :id, :bigint, autoincrement: true
    change_column :members, :id, :bigint, autoincrement: true
    change_column :pc_results, :id, :bigint, autoincrement: true
    change_column :pf_results, :id, :bigint, autoincrement: true
    change_column :pfj_results, :id, :bigint, autoincrement: true
    change_column :pilot_flights, :id, :bigint, autoincrement: true
    change_column :region_contests, :id, :bigint, autoincrement: true
    change_column :regional_pilots, :id, :bigint, autoincrement: true
    change_column :results, :id, :bigint, autoincrement: true
    change_column :result_accums, :id, :bigint, autoincrement: true
    change_column :result_members, :id, :bigint, autoincrement: true
    change_column :scores, :id, :bigint, autoincrement: true
    change_column :sequences, :id, :bigint, autoincrement: true
    change_column :synthetic_categories, :id, :bigint, autoincrement: true

  end

end
