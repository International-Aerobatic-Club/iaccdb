class CreateFreeProgramKs < ActiveRecord::Migration[5.1]
  def change
    create_table :free_program_ks do |t|
      t.integer :year
      t.references :category, foreign_key: true
      t.integer :max_k
      t.timestamps
    end
  end
end
