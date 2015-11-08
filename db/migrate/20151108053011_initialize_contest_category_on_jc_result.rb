class InitializeContestCategoryOnJcResult < ActiveRecord::Migration
  def up
    JcResult.all.each do |jc_result|
      c_result = jc_result.c_result
      if (c_result)
        jc_result.contest_id = c_result.contest_id
        jc_result.category_id = c_result.category_id
        jc_result.save
      else
        # they are useless if we don't know what contest and category
        # and anyway, derived information.
        # clean this up.
        jc_result.delete
      end
    end
  end
  def down
  end
end
