module ACRO
  describe ResultScraper do
    before(:all) do
      @rs = ResultScraper.new(data_sample_file('multi_R011s08s17s26.htm'))
    end
    it 'finds the category and title' do
      expect(@rs.description).to eq 'US National Champion - Unlimited'
      expect(@rs.category_name).to eq 'Unlimited'
    end
    it 'finds the list of pilots' do
      expect(@rs.pilots).to_not be_nil
      expect(@rs.pilots.count).to eq 12
      expect(@rs.pilots[0]).to eq 'Rob Holland'
      expect(@rs.pilots[5]).to eq 'Melissa Pemberton'
      expect(@rs.pilots[11]).to eq 'Joe Brinker'
    end
    it 'finds the list of flights' do
      expect(@rs.flights).to_not be_nil
      expect(@rs.flights.count).to eq 3
      expect(@rs.flights[0]).to eq 'Known P1'
      expect(@rs.flights[1]).to eq 'Free #1'
      expect(@rs.flights[2]).to eq 'FreeUnk1'
    end
    it 'finds flight totals' do
      expect(@rs.flight_total(0,0)).to eq 3570.85
      expect(@rs.flight_total(0,1)).to eq 3631.86
      expect(@rs.flight_total(0,2)).to eq 3890.08
      expect(@rs.flight_total(5,0)).to eq 3194.43
      expect(@rs.flight_total(5,1)).to eq 3416.88
      expect(@rs.flight_total(5,2)).to eq 3561.75
      expect(@rs.flight_total(11,0)).to eq 2392.27
      expect(@rs.flight_total(11,1)).to eq 3418.82
      expect(@rs.flight_total(11,2)).to eq 1545.11
    end
    it 'finds result totals' do
      expect(@rs.result(0)).to eq 11092.78
      expect(@rs.result(5)).to eq 10173.06
      expect(@rs.result(11)).to eq 7356.2
    end
    it 'finds result percentages' do
      expect(@rs.result_percentage(0)).to eq 81.926
      expect(@rs.result_percentage(5)).to eq 75.133
      expect(@rs.result_percentage(11)).to eq 54.329
    end
  end
end
