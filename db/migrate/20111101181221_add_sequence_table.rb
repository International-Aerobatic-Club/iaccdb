class AddSequenceTable < ActiveRecord::Migration
  def self.up
    create_table :sequences do |t|
      t.integer :figure_count
      t.integer :total_k
      t.integer :mod_3_total
      t.string :k_values
    end
    add_index (:sequences, 
      [:figure_count, :total_k, :mod_3_total], 
      :name => 'by_attrs')
  end

  def self.down
    drop_table :sequences   
  end
end
