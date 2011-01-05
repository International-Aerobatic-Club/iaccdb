require 'test_helper'

class ScoreTest < ActiveSupport::TestCase
  test "pilot flight scores" do
    p1 = pilot_flights(:one)
    assert_not_nil(p1)
    scores = p1.scores
    assert_not_nil(scores)
    assert_equal(2, scores.length)
    j1 = judges(:one)
    assert_not_nil(j1)
    js = j1.scores
    assert_not_nil(js)
    assert_equal(3, js.length)
    s = scores & js
    assert_equal(1, s.length)
    sv = s[0].values
    assert_equal(Array, sv.class)
    [70, 80, 90, 75, 65, 70, 80, 85, 90, 65].each_with_index do |v, i|
      assert_equal(v, sv[i])
    end
  end
end
