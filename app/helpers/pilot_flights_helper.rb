module PilotFlightsHelper
  def ptsLoT(pts, k)
    Score.display_score(k * 100 - pts)
  end

  def avg(pts, k)
    Score.display_score(pts.fdiv(k))
  end
end
