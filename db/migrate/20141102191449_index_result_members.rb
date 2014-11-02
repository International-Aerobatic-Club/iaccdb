class IndexResultMembers < ActiveRecord::Migration
  def change
    change_table :result_members do |t|
      t.index :member_id
      t.index :result_id
      t.index([:member_id, :result_id], unique:true)
    end
  end
end
