module IAC
  describe RegionalSeries do
    before :context do
      @year = 2015
      @region = 'NorthEast'
      start = Time.mktime(@year)
      c_ntnls = create(:contest, start: start,
        region: 'National',
        name: 'U.S. National Aerobatic Championships')
      c_olean = create(:contest, start: start,
        region: @region,
        name: 'Bill Thomas US - Canada Aerobatic Challenge')
      c_east = create(:contest, start: start,
        region: @region,
        name: 'East Coast Aerobatic Contest')
      @c_green = create(:contest, start: start,
        region: @region,
        name: 'Green Mountain Aerobatic Contest')
      c_carolina = create(:contest, start: start,
        region: @region,
        name: 'Carolina Boogie')
      @c_kjc = create(:contest, start: start,
        region: @region,
        name: 'Kathy Jaffe Challenge')
      @c_blue = create(:contest, start: start,
        region: @region,
        name: 'Blue Ridge Hammerfest')
      @spn = Category.find_for_cat_aircat('sportsman', 'P')

      @pilot_taylor = Member.create(
        iac_id: 2112, given_name: 'David',
        family_name: 'Taylor')
      PcResult.create(pilot: @pilot_taylor,
        category: @spn,
        contest: @c_green,
        category_value: 2123.36, total_possible: 2720)
      PcResult.create(pilot: @pilot_taylor,
        category: @spn,
        contest: c_olean,
        category_value: 3384.33, total_possible: 4080)
      PcResult.create(pilot: @pilot_taylor,
        category: @spn,
        contest: c_east,
        category_value: 2288.00, total_possible: 2720)
      PcResult.create(pilot: @pilot_taylor,
        category: @spn,
        contest: c_ntnls,
        category_value: 3360.26, total_possible: 4080)

      @pilot_schreck = Member.create(
        iac_id: 21298,
        given_name: 'Ron', 
        family_name: 'Schreck')
      PcResult.create!(pilot: @pilot_schreck,
        category: @spn,
        contest: c_carolina,
        category_value: 3463.17, total_possible: 4080)
      PcResult.create(pilot: @pilot_schreck,
        category: @spn,
        contest: @c_kjc,
        category_value: 2865.38, total_possible: 4080)
      PcResult.create(pilot: @pilot_schreck,
        category: @spn,
        contest: c_east,
        category_value: 2237.83, total_possible: 2720)
      PcResult.create(pilot: @pilot_schreck,
        category: @spn,
        contest: @c_blue,
        category_value: 3322.33, total_possible: 4080)

      @pilot_smith = Member.create(
        iac_id: 21238,
        given_name: 'Ron', 
        family_name: 'Smith')
      PcResult.create(pilot: @pilot_smith,
        category: @spn,
        contest: @c_green,
        category_value: 1953.10, total_possible: 2720)
      PcResult.create(pilot: @pilot_smith,
        category: @spn,
        contest: @c_kjc,
        category_value: 2829.13, total_possible: 4080)

      @computer = RegionalSeries.new
      @computer.compute_results(@year, @region)
    end

    it 'computes region result in category' do
      rt = RegionalPilot.where(
        pilot: @pilot_taylor,
        region: @region,
        year: @year)
      expect(rt).to_not be nil
      expect(rt.count).to eq 1
      rt = rt.first
      expect(rt).to_not be nil
      expect(rt.percentage).to eq 83.02
      expect(rt.qualified).to be true
      expect(rt.category).to eq @spn
    end

    context 'hc results' do
      before :context do
        PcResult.create(pilot: @pilot_smith,
          category: @spn,
          contest: @c_blue,
          hors_concours: true,
          category_value: 4080.00, total_possible: 4080)
        @computer.compute_results(@year, @region)
      end
      it 'omits HC computing pilot' do
        expect(@pilot_smith.pc_results.count).to eq 3
        rs = RegionalPilot.where(
          pilot: @pilot_smith,
          region: @region,
          year: @year)
        expect(rs).to_not be nil
        expect(rs.count).to eq 1
        rs = rs.first
        expect(rs).to_not be nil
        expect(rs.pc_results.count).to eq 2
        expect(rs.percentage).to eq 70.33
        expect(rs.qualified).to be false
        expect(rs.category).to eq @spn
      end
    end

    context 'four minute' do
      before :context do
        four = Category.find_for_cat_aircat('four minute', 'F')
        @pilot_dumovic = Member.create(
          iac_id: 21224,
          given_name: 'Robert', 
          family_name: 'Dumovic')
        PcResult.create(pilot: @pilot_dumovic,
          category: four,
          contest: @c_blue,
          category_value: 3500.00, total_possible: 4000)
        PcResult.create(pilot: @pilot_dumovic,
          category: four,
          contest: @c_green,
          category_value: 2500.00, total_possible: 4000)
        PcResult.create(pilot: @pilot_dumovic,
          category: four,
          contest: @c_kjc,
          category_value: 3000.00, total_possible: 4000)
        @computer.compute_results(@year, @region)
      end
      it 'omits four minute free category' do
        expect(@pilot_dumovic.pc_results.count).to eq 3
        rs = RegionalPilot.where(
          pilot: @pilot_dumovic,
          region: @region,
          year: @year)
        expect(rs).to_not be nil
        expect(rs.count).to eq 0
      end
    end
  end
end
