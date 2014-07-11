class CreateRegionalPilots < ActiveRecord::Migration
  def self.up
    create_table :regional_pilots do |t|
      t.id :pilot_id
      t.string :region, :limit => 16, :null => false
      t.int :year
      t.decimal :percentage, :precision => 5, :scale => 2
      t.boolean :qualified, :default => false
      t.int :rank

      t.timestamps
    end
  end

  def self.down
    drop_table :regional_pilots
  end
end
