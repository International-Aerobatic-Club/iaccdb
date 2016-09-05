module IAC
  describe SoucyComputer do
    before :each do
      @year = 2015
      start = Time.mktime(@year)
      @region = 'SouthCentral'
      @c_hamm = create(:contest, start: start,
        region: @region,
        name: 'Hammerhead Round Up')
      @c_duel = create(:contest, start: start,
        region: @region,
        name: 'Duel in the Desert')
      @c_coal = create(:contest, start: start,
        region: @region,
        name: 'Coalinga Western Showdown')
      @c_delano = create(:contest, start: start,
        region: @region,
        name: 'Happiness is Delano')
      @c_borrego = create(:contest, start: start,
        region: @region,
        name: 'Borrego Akrofest')
      @c_ntnls = create(:contest, start: start,
        region: 'National',
        name: 'U.S. National Aerobatic Championships')
      @c_mac = create(:contest, start: @start,
        region: 'SouthCentral',
        name: 'MAC80 West')

      @spn = Category.find_for_cat_aircat('sportsman', 'P')

      @pilot_elizondo = Member.create(
        iac_id: 2112, given_name: 'Kevin',
        family_name: 'Elizondo')

      PcResult.create(pilot: @pilot_elizondo,
        category: @spn,
        contest: @c_hamm,
        category_value: 3391.00, total_possible: 4080)
      PcResult.create(pilot: @pilot_elizondo,
        category: @spn,
        contest: @c_duel,
        category_value: 3517.50, total_possible: 4080)
      PcResult.create(pilot: @pilot_elizondo,
        category: @spn,
        contest: @c_coal,
        category_value: 3544.06, total_possible: 4080)
      @high_result = PcResult.create(pilot: @pilot_elizondo,
        category: @spn,
        contest: @c_delano,
        category_value: 3583.38, total_possible: 4080)
      PcResult.create(pilot: @pilot_elizondo,
        category: @spn,
        contest: @c_borrego,
        category_value: 3454.90, total_possible: 4080)
      PcResult.create(pilot: @pilot_elizondo,
        category: @spn,
        contest: @c_ntnls,
        category_value: 3410.03, total_possible: 4080)

      @computer = SoucyComputer.new(@year)
      @computer.recompute
    end

    it 'computes soucy result for a pilot' do
      rt = SoucyResult.where(
        pilot: @pilot_elizondo,
        year: @year)
      expect(rt).to_not be nil
      expect(rt.count).to eq 1
      rt = rt.first
      expect(rt).to_not be nil
      expect(rt.result_percent.round(2)).to eq 86.09
    end

    it 'computes correctly when pc_result destroyed' do
      @high_result.destroy
      @computer.recompute
      rt = SoucyResult.where(
        pilot: @pilot_elizondo,
        year: @year).first
      expect(rt.result_percent.round(2)).not_to eq 86.09
      expect(rt.result_percent.round(2)).to eq 85.55
    end

    it 'computes correctly when pc_result changes to hc' do
      @high_result.hors_concours = true;
      @high_result.save
      @computer.recompute
      rt = SoucyResult.where(
        pilot: @pilot_elizondo,
        year: @year).first
      expect(rt.result_percent.round(2)).not_to eq 86.09
      expect(rt.result_percent.round(2)).to eq 85.55
    end

    context 'hc results' do
      before :each do
        PcResult.create(pilot: @pilot_elizondo,
          category: @spn,
          contest: @c_mac,
          hors_concours: true,
          category_value: 4080.00, total_possible: 4080)
        @computer.recompute
      end
      it 'omits HC computing pilot' do
        expect(@pilot_elizondo.pc_results.count).to eq 7
        rs = SoucyResult.where(
          pilot: @pilot_elizondo,
          year: @year)
        expect(rs).to_not be nil
        expect(rs.count).to eq 1
        rs = rs.first
        expect(rs).to_not be nil
        expect(rs.pc_results.count).to eq 6
        expect(rs.result_percent.round(2)).to eq 86.09
      end
    end

    context 'four minute' do
      before :each do
        @four_minute_cat = Category.find_for_cat_aircat('four minute', 'F')
      end
      it 'omits four minute free at regional' do
        PcResult.create(pilot: @pilot_elizondo,
          category: @four_minute_cat,
          contest: @c_mac,
          category_value: 4000.00, total_possible: 4000)
        @computer.recompute
        expect(@pilot_elizondo.pc_results.count).to eq 7
        rs = SoucyResult.where(
          pilot: @pilot_elizondo,
          year: @year)
        expect(rs).to_not be nil
        expect(rs.count).to eq 1
        rs = rs.first
        expect(rs).to_not be nil
        expect(rs.pc_results.count).to eq 6
        expect(rs.result_percent.round(2)).to eq 86.09
      end
      it 'omits four minute free at Nationals' do
        PcResult.create(pilot: @pilot_elizondo,
          category: @four_minute_cat,
          contest: @c_ntnls,
          category_value: 4000.00, total_possible: 4000)
        @computer.recompute
        expect(@pilot_elizondo.pc_results.count).to eq 7
        rs = SoucyResult.where(
          pilot: @pilot_elizondo,
          year: @year)
        expect(rs).to_not be nil
        expect(rs.count).to eq 1
        rs = rs.first
        expect(rs).to_not be nil
        expect(rs.pc_results.count).to eq 6
        expect(rs.result_percent.round(2)).to eq 86.09
      end
      it 'removes existing soucy four minute relationship' do
        # it recovers from the former error
        # fake this by changing category on a contest
        # already included on the current computation
        @high_result.category = @four_minute_cat
        @high_result.save
        @computer.recompute
        expect(@pilot_elizondo.pc_results.count).to eq 6
        rs = SoucyResult.where(
          pilot: @pilot_elizondo,
          year: @year)
        expect(rs).to_not be nil
        expect(rs.count).to eq 1
        rs = rs.first
        expect(rs).to_not be nil
        expect(rs.pc_results.count).to eq 5
        expect(rs.result_percent.round(2)).to_not eq 86.09
      end
    end
  end
end
