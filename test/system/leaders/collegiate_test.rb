require 'test_helper'

class LeadersCollegiateTest < ActionDispatch::IntegrationTest
  test "highlights non-qualifying collegiate results" do
    year = 2024
    qualified = CollegiateResult.create!(
      name: 'Qualified University',
      year: year,
      qualified: true,
      rank: 1,
      points: 90,
      points_possible: 100
    )
    non_qualified = CollegiateResult.create!(
      name: 'Almost University',
      year: year,
      qualified: false
    )

    get leaders_collegiate_path(year)

    assert_select('table.collegiate tbody tr.collegiate_team td.team_name',
      qualified.name)
    assert_select('div.non-qual') do
      assert_select('h2', 'Non-Qualifying Results:')
      assert_select('table.collegiate tbody tr.collegiate_team td.team_name',
        non_qualified.name)
      assert_no_match(qualified.name, css_select('div.non-qual').first.text)
    end
  end
end
