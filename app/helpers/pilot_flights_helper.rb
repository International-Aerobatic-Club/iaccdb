module PilotFlightsHelper
  def ptsLoT(pts, k)
    Score.display_score(k * 100 - pts)
  end

  def avg(pts, k)
    if (0 < k)
      Score.display_score(pts.fdiv(k))
    else
      0.0
    end
  end

  def rank(rank)
    if rank
      "(#{sprintf('%2d', rank)})"
    else
      ''
    end
  end

  def figure_rank(ranks, f)
    if ranks
      rank(ranks[f])
    else
      ''
    end
  end

  def points(points)
    decimal_two(points)
  end

  def show_judge_team(judge_team)
    team_name = judge_team.judge.name
    if judge_team.assist
      team_name += " with " + judge_team.assist.name
    end
  end
end
