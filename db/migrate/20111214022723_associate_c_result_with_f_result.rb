class AssociateCResultWithFResult < ActiveRecord::Migration
  def self.up
    change_table :f_results do |t|
      t.integer :c_result_id
    end
  end

  def self.down
    change_table :f_results do |t|
      t.remove :c_result_id
    end
  end
end
