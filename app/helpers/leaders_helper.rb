module LeadersHelper
  def region_category_link_name(region, category)
    [region, category].join('-').gsub(' ','-')
  end

  def judge_leaders_cat_id(category)
    "judge-leaders-category-#{category.id}"
  end
end
