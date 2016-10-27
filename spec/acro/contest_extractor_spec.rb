module ACRO
  require 'fileutils'
  describe ContestExtractor do
    before :context do
      setup_contest_extracted_data
    end
    after :context do
      cleanup_contest_extracted_data
    end
    it 'creates pilot flight yml files' do
      expect(File.exists?(contest_data_file('pilot_p001s16.htm.yml'))).to eq true
      expect(File.exists?(contest_data_file('pilot_p002s17.htm.yml'))).to eq true
      expect(File.exists?(contest_data_file('pilot_p035s09.htm.yml'))).to eq true
      pfd = YAML.load_file(contest_data_file('pilot_p035s09.htm.yml'))
      expect(pfd).to_not be_nil
      expect(pfd.judges).to_not be nil
      expect(pfd.judges.size).to eq 7
      expect(pfd.judges[0]).to eq 'Chris Rudd'
      expect(pfd.pilotName).to eq 'Rob Holland'
      expect(pfd.pilotID).to eq 35
      expect(pfd.registration).to eq 'N540JH'
      expect(pfd.aircraft).to eq 'MXS'
      expect(pfd.flightID).to eq 9
      expect(pfd.flightName).to eq 'Unlimited Power : 1st Unknown Sequence'
      expect(pfd.k_factors).to_not be_nil
      expect(pfd.k_factors.size).to eq 14
      expect(pfd.k_factors[2]).to eq 9
      expect(pfd.scores).to_not be_nil
      expect(pfd.scores.size).to eq 7
      expect(pfd.scores[0].size).to eq 14
      expect(pfd.scores[0][0]).to eq 85
      expect(pfd.scores[6][13]).to eq 95
    end
    it 'creates category yml files' do
      multi_yml = data_sample_file('multi_R011s08s17s26.htm.yml')
      expect(File.exists?(multi_yml)).to eq true
      cr = YAML.load_file(multi_yml)
      expect(cr).to_not be_nil
      expect(cr.category_name).to eq 'Unlimited'
      expect(cr.description).to eq 'US National Champion - Unlimited'
      expect(cr.pilots).to_not be_nil
      expect(cr.pilots.length).to be 12
      expect(cr.pilots[0]).to eq 'Rob Holland'
      expect(cr.pilots[11]).to eq 'Joe Brinker'
      expect(cr.flight_names).to_not be_nil
      expect(cr.flight_names.length).to eq 3
      expect(cr.flight_names[1]).to eq 'Free #1'
      expect(cr.flight_results).to_not be_nil
      expect(cr.flight_results.length).to eq 12
      expect(cr.flight_results[0].length).to eq 3
      expect(cr.flight_results[0][0]).to eq 3570.85
      expect(cr.category_results).to_not be_nil
      expect(cr.category_results.length).to eq 12
      expect(cr.category_results[0]).to eq 11092.78
      expect(cr.category_percentages).to_not be_nil
      expect(cr.category_percentages.length).to eq 12
      expect(cr.category_percentages[0]).to eq 81.926
    end
  end
end
