class IndexIdColumns < ActiveRecord::Migration
  def change
    add_index :airplanes, :id
    add_index :c_results, :id
    add_index :categories, :id
    add_index :contests, :id
    add_index :data_posts, :id
    add_index :f_results, :id
    add_index :failures, :id
    add_index :flights, :id
    add_index :jc_results, :id
    add_index :jf_results, :id
    add_index :judges, :id
    add_index :jy_results, :id
    add_index :members, :id
    add_index :pc_results, :id
    add_index :pf_results, :id
    add_index :pfj_results, :id
    add_index :pilot_flights, :id
    add_index :region_contests, :id
    add_index :regional_pilots, :id
    add_index :results, :id
    add_index :scores, :id
    add_index :sequences, :id
    add_index :writers, :id
  end
end
