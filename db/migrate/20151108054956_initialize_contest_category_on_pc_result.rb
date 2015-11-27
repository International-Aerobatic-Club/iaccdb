class InitializeContestCategoryOnPcResult < ActiveRecord::Migration
  def up
    PcResult.all.each do |pc_result|
      c_result = pc_result.c_result
      if (c_result)
        pc_result.contest_id = c_result.contest_id
        pc_result.category_id = c_result.category_id
        pc_result.save
      else
        # they are useless if we don't know what contest and category
        # and anyway, derived information.
        # clean this up.
        pc_result.delete
      end
    end
  end
  def down
  end
end
