module FurtherHelper
  # cy indexed by category_id, entries indexed by year
  # c category_id
  # y year
  # m method to call on entry selected by category and year
  # protects for missing category x year, in which case returns an empty string
  def cat_year_select(cy, c, y, m)
    val = ''
    cyc = cy[c]
    cycy = cyc[y] if cyc
    if cycy
      begin
        val = cycy.first.send(m)
      rescue
      end
    end
    val
  end
end
