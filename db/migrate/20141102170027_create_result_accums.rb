class CreateResultAccums < ActiveRecord::Migration
  def change
    create_table :result_accums do |t|
      t.integer :result_id
      t.integer :pc_result_id
      t.timestamps
    end
  end
end
