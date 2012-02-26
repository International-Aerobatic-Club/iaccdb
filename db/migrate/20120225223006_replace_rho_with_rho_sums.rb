class ReplaceRhoWithRhoSums < ActiveRecord::Migration
  def self.up
    change_table :jc_results do |t|
      t.integer  "ftsdx2"
      t.integer  "ftsdxdy"
      t.integer  "ftsdy2"
      t.integer  "sigma_d2"
      t.remove :rho
      t.remove :cc
    end
    change_table :jf_results do |t|
      t.integer  "ftsdx2"
      t.integer  "ftsdxdy"
      t.integer  "ftsdy2"
      t.integer  "sigma_d2"
      t.integer  "pair_count"
      t.remove :rho
      t.remove :cc
    end
  end

  def self.down
    change_table :jc_results do |t|
      t.remove  "sigma_d2"
      t.remove  "ftsdxdy"
      t.remove  "ftsdx2"
      t.remove  "ftsdy2"
      t.integer :rho
      t.integer :cc
    end
    change_table :jf_results do |t|
      t.remove  "sigma_d2"
      t.remove  "ftsdxdy"
      t.remove  "ftsdx2"
      t.remove  "ftsdy2"
      t.remove  "pair_count"
      t.integer :rho
      t.integer :cc
    end
  end
end
