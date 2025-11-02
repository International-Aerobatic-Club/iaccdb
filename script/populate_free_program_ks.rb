# (Re-)Populate the database's `free_program_k` objects

# Retrieve the `Category#id` values for Sportsman thru Unlimited, both Power and Glider.
# The result is a Hash in which the keys are the category names ("Primary Power", etc.) and the values
# are the corresponding `Category#id`.
CATEGORY_IDS = {
  SPTP: "Sportsman Power",
  INTP: "Intermediate Power",
  ADVP: "Advanced Power",
  UNLP: "Unlimited Power",
  SPTG: "Sportsman Glider",
  INTG: "Intermediate Glider",
  ADVG: "Advanced Glider",
  UNLG: "Unlimited Glider",
}.map{ |abbr, name| [abbr, Category.find_by(name: name).id] }.to_h.freeze

# Note: `nil` values indicate that the corresponding category did not exist during the years in question.
K_FACTOR_LIMITS = {

  y2005: { SPTP: 115, INTP: 190, ADVP: 300, UNLP: 420, SPTG: nil, INTG: 140, ADVG: nil, UNLG: 220, },
  y2006: { SPTP: 133, INTP: 198, ADVP: 312, UNLP: 446, SPTG: nil, INTG: 155, ADVG: nil, UNLG: 265, },
  y2007: { SPTP: 138, INTP: 198, ADVP: 312, UNLP: 446, SPTG: 140, INTG: 155, ADVG: nil, UNLG: 265, },
  y2008: { SPTP: 138, INTP: 198, ADVP: 312, UNLP: 446, SPTG: 117, INTG: 155, ADVG: nil, UNLG: 265, },
  y2009: { SPTP: 131, INTP: 198, ADVP: 312, UNLP: 446, SPTG: 109, INTG: 155, ADVG: nil, UNLG: 265, },
  y2010: { SPTP: 143, INTP: 198, ADVP: 312, UNLP: 446, SPTG: 128, INTG: 155, ADVG: nil, UNLG: 265, },
  y2011: { SPTP: 133, INTP: 198, ADVP: 312, UNLP: 446, SPTG: 139, INTG: 155, ADVG: nil, UNLG: 265, },
  y2012: { SPTP: 130, INTP: 198, ADVP: 312, UNLP: 446, SPTG: 142, INTG: 155, ADVG: 195, UNLG: 265, },
  y2013: { SPTP: 155, INTP: 198, ADVP: 312, UNLP: 446, SPTG: 142, INTG: 155, ADVG: 195, UNLG: 265, },
  y2014: { SPTP: 142, INTP: 198, ADVP: 312, UNLP: 446, SPTG: 121, INTG: 155, ADVG: 210, UNLG: 265, },
  y2015: { SPTP: 136, INTP: 198, ADVP: 312, UNLP: 446, SPTG: 132, INTG: 155, ADVG: 210, UNLG: 265, },
  y2016: { SPTP: 132, INTP: 198, ADVP: 312, UNLP: 446, SPTG: 111, INTG: 155, ADVG: 210, UNLG: 265, },
  y2017: { SPTP: 139, INTP: 198, ADVP: 312, UNLP: 446, SPTG: 155, INTG: 155, ADVG: 210, UNLG: 265, },
  y2018: { SPTP: 127, INTP: 198, ADVP: 312, UNLP: 446, SPTG: 118, INTG: 155, ADVG: 210, UNLG: 265, },
  y2019: { SPTP: 129, INTP: 205, ADVP: 325, UNLP: 460, SPTG: 136, INTG: 155, ADVG: 210, UNLG: 265, },
  y2020: { SPTP: 139, INTP: 190, ADVP: 300, UNLP: 420, SPTG: 109, INTG: 140, ADVG: 175, UNLG: 230, },
  y2021: { SPTP: 125, INTP: 190, ADVP: 300, UNLP: 420, SPTG: 109, INTG: 140, ADVG: 175, UNLG: 230, },
  y2022: { SPTP: 137, INTP: 190, ADVP: 300, UNLP: 420, SPTG: 131, INTG: 140, ADVG: 175, UNLG: 230, },
  y2023: { SPTP: 130, INTP: 190, ADVP: 300, UNLP: 420, SPTG: 119, INTG: 140, ADVG: 175, UNLG: 230, },
  y2024: { SPTP: 139, INTP: 190, ADVP: 300, UNLP: 420, SPTG: 124, INTG: 140, ADVG: 175, UNLG: 230, },
  y2025: { SPTP: 125, INTP: 190, ADVP: 300, UNLP: 420, SPTG: 115, INTG: 140, ADVG: 175, UNLG: 230, },

}.freeze


FreeProgramK.transaction do

  FreeProgramK.delete_all

  K_FACTOR_LIMITS.each do |year, kfs|

    year = year.to_s.delete('y').to_i

    kfs.each do |abbr, max_k|
      FreeProgramK.create!(
        category_id: CATEGORY_IDS[abbr],
        year: year,
        max_k: max_k,
      ) unless max_k.nil?
    end

  end

end
