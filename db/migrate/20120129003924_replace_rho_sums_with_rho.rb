class ReplaceRhoSumsWithRho < ActiveRecord::Migration
  def self.up
    change_table :jc_results do |t|
      t.remove  "sigma_d2"
      t.remove  "sigma_pj"
      t.remove  "sigma_p2"
      t.remove  "sigma_j2"
      t.integer :rho
      t.integer :cc
    end
    change_table :jf_results do |t|
      t.remove  "sigma_d2"
      t.remove  "sigma_pj"
      t.remove  "sigma_p2"
      t.remove  "sigma_j2"
      t.integer :rho
      t.integer :cc
    end
  end

  def self.down
    change_table :jc_results do |t|
      t.integer  "sigma_d2"
      t.integer  "sigma_pj"
      t.integer  "sigma_p2"
      t.integer  "sigma_j2"
      t.remove :rho
      t.remove :cc
    end
    change_table :jf_results do |t|
      t.integer  "sigma_d2"
      t.integer  "sigma_pj"
      t.integer  "sigma_p2"
      t.integer  "sigma_j2"
      t.remove :rho
      t.remove :cc
    end
  end
end
