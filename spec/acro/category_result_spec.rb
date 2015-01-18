module ACRO
  describe CategoryResult do
    before :all do
      @cr = CategoryResult.new
    end
    it 'accepts a pilot' do
      tommy = 'Major Tom'
      @cr.pilots << tommy
      expect(@cr.pilots.length).to be 1
      expect(@cr.pilots.first).to be tommy
    end
  end
end
