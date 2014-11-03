class IndexResultMembers < ActiveRecord::Migration
  def up
    change_table :result_members do |t|
      t.index :member_id
      t.index :result_id
      t.index([:member_id, :result_id], unique:true)
    end
  end
  def down
  end
end
