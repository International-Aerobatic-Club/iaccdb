module LeadersHelper
def region_category_link_name(region, category)
  [region, category].join('-').gsub(' ','-')
end
end
