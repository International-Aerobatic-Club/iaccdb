require 'test_helper'

class JudgeTest < ActiveSupport::TestCase
  test "judge member hookup" do
    assert_equal(2, Judge.count)
    judge = Judge.find_by_judge_id(members(:one))
    assert_equal(members(:two), judge.assist)
    jj = judge.judge
    assert_equal('Michael', jj.given_name)
    judge = Judge.find_by_assist_id(members(:three))
    assert_equal(members(:four), judge.judge)
    ja = judge.assist
    assert_equal('Hill', ja.family_name)
  end
end
