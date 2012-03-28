class FixOrphanJfResult < ActiveRecord::Migration
  def self.up
    JfResult.find_all_by_f_result_id(nil).each {|j| j.destroy}
    JfResult.find_all_by_jc_result_id(nil).each {|j| j.destroy}
  end

  def self.down
  end
end
