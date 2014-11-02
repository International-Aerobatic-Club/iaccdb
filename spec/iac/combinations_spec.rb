module IAC
  class R
    attr_reader :count
    attr_reader :max
    attr_reader :best
    def initialize
      @count = 0
      @register = []
      @max = 0
      @value = 0
      @best = nil
    end
    def evaluate
      @count += 1
      if @max < @value
        @max = @value
        @best = @register.clone
      end
    end
    def accumulate(e)
      @register.push(e)
      @value += e
    end
    def rollback
      @value -= @register.pop
    end
  end
  describe Combinations do
    before :all do
      @a = [1,4,5,2,3]
    end
    it 'gets all two-combinations' do
      ct = 0
      @a.combination(2) { |c| ct = ct + 1 }
      r = R.new
      Combinations.compute(@a, r, 2)
      expect(r.count).to eq ct
    end
    it 'gets all three-combinations' do
      ct = 0
      @a.combination(3) { |c| ct = ct + 1 }
      r = R.new
      Combinations.compute(@a, r, 3)
      expect(r.count).to eq ct
    end
    it 'finds the maximum' do
      r = R.new
      Combinations.compute(@a, r, 3)
      expect(r.max).to eq 12
      expect(r.best.size).to eq 3
      expect(r.best.sort[0]).to eq 3
      expect(r.best.sort[1]).to eq 4
      expect(r.best.sort[2]).to eq 5
    end
    it 'gets all one-combinations' do
      r = R.new
      Combinations.compute(@a, r, 1)
      expect(r.count).to eq 5
    end
  end
end
