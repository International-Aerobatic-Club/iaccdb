class CreateResultMembers < ActiveRecord::Migration
  def change
    create_table :result_members do |t|
      t.integer :member_id
      t.integer :result_id
      t.timestamps
    end
  end
end
