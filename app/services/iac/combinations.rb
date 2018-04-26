module IAC
# unlike Array.combination, this enables incremental computation
# as each combination is built.
class Combinations
  # compute all count-combinations on candidates
  # result evaluates combinations and stores the result
  # result should respond to:
  #   evaluate - called to evaluate a complet accumulated combination
  #   accumulate(e) - accumulate element e into the current combination
  #   rollback - reverse effect of prior accumulation
  def self.compute(candidates, result, count)
    if (count == 0)
      result.evaluate
    else
      (0 .. candidates.size - count).each do |i|
        result.accumulate(candidates[i])
        self.compute(candidates[i+1..candidates.size], result, count-1)
        result.rollback
      end
    end
  end
end
end
