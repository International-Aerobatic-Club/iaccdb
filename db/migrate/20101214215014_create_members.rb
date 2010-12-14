class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.integer :iac_id
      t.string :given_name, :limit => 40
      t.string :family_name, :limit => 40
      t.timestamps
      t.primary_key :iac_id
    end
  end

  def self.down
    drop_table :members
  end
end
