module ApplicationHelper
  def decimal_two(v)
    sprintf('%.02f', v  ? v : 0)
  end

  def score_two(v)
    v ||= 0
    decimal_two(v.fdiv(10))
  end

  def score_pct_two(n,d)
    n ||= 0
    d ||= 1
    decimal_two((n * 10.0).fdiv(d))
  end

  def decimal_pct_two(n,d)
    n ||= 0
    d ||= 1
    decimal_two((n * 100.0).fdiv(d))
  end

  def k_score_two(k)
    k ||= 0
    decimal_two(k * 10)
  end
end
