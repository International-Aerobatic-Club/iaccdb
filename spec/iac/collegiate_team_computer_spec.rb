module IAC
  describe CollegiateComputer do
    before :context do
      pcrs = []
      @year = 2016
      start = Time.mktime(@year)
      c_ntnls = create(:contest, start: start,
        name: 'U.S. National Aerobatic Championships')
      c_mac80 = create(:contest, start: start,
        name: 'MAC80 : IAC Open West Championships')
      c_youst = create(:contest, start: start,
        name: 'Doug Youst Challenge')
      c_canam = create(:contest, start: start,
        name: 'Rocky Mountin Can-Am')
      @c_michg = create(:contest, start: start,
        name: 'Michigan Aerobatic Open')
      pri = Category.find_for_cat_aircat('primary', 'P')
      @spn = Category.find_for_cat_aircat('sportsman', 'P')
      adv = Category.find_for_cat_aircat('advanced', 'P')
      @team = CollegiateResult.new(name: 'UND', year: @year)
      @mills = CollegiateIndividualResult.create(name: 'Patrick Mills', 
        year: @year)

      @pilot_mills = Member.create(
        iac_id: 877212, given_name: 'Patrick', 
        family_name: 'Mills')
      pcrs << PcResult.create(pilot: @pilot_mills,
        category: @spn,
        contest: c_mac80,
        category_value: 3315.30, total_possible: 4080)
      pcrs << PcResult.create(pilot: @pilot_mills,
        category: @spn,
        contest: c_canam,
        category_value: 3302.50, total_possible: 4080)
      pcrs << PcResult.create(pilot: @pilot_mills,
        category: @spn,
        contest: c_youst,
        category_value: 3345.26, total_possible: 4080)
      pcrs << PcResult.create(pilot: @pilot_mills,
        category: @spn,
        contest: c_ntnls,
        category_value: 3311.10, total_possible: 4080)
      @team.members << @pilot_mills
      @mills.pilot = @pilot_mills
      @mills.pc_results << pcrs
      @mills.save

      p = Member.create(
        iac_id: 304606,
        given_name: 'Cameron', 
        family_name: 'Jaxheimer')
      pcrs << PcResult.create(pilot: p,
        category: adv,
        contest: c_mac80,
        category_value: 6293.90, total_possible: 9050)
      pcrs << PcResult.create(pilot: p,
        category: adv,
        contest: @c_michg,
        category_value: 7295.76, total_possible: 9050)
      pcrs << PcResult.create(pilot: p,
        category: adv,
        contest: c_canam,
        category_value: 7044.50, total_possible: 9050)
      pcrs << PcResult.create(pilot: p,
        category: adv,
        contest: c_youst,
        category_value: 7264.21, total_possible: 9050)
      pcrs << PcResult.create(pilot: p,
        category: adv,
        contest: c_ntnls,
        category_value: 7200.41, total_possible: 9410)
      @team.members << p

      p = Member.create(
        iac_id: 518914,
        given_name: 'Alexander', 
        family_name: 'Volberding')
      pcrs << PcResult.create(pilot: p,
        category: @spn,
        contest: c_mac80,
        category_value: 2984.42, total_possible: 4080)
      pcrs << PcResult.create(pilot: p,
        category: @spn,
        contest: c_youst,
        category_value: 3162.88, total_possible: 4080)
      pcrs << PcResult.create(pilot: p,
        category: @spn,
        contest: c_ntnls,
        category_value: 3114.14, total_possible: 4080)
      @team.members << p

      p = Member.create(
        iac_id: 614888,
        given_name: 'Christian', 
        family_name: 'Schrimpf')
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_mac80,
        category_value: 1422.10, total_possible: 1680)
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_youst,
        category_value: 1496.34, total_possible: 1680)
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_ntnls,
        category_value: 1414.20, total_possible: 1680)
      @team.members << p

      p = Member.create(
        iac_id: 303704, 
        given_name: 'Deven', 
        family_name: 'Romain')
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_youst,
        category_value: 1412.67, total_possible: 1680)
      @team.members << p

      p = Member.create(
        iac_id: 201845, 
        given_name: 'John', 
        family_name: 'Perillo')
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_mac80,
        category_value: 1363.30, total_possible: 1680)
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_youst,
        category_value: 1457.17, total_possible: 1680)
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_ntnls,
        category_value: 1410.15, total_possible: 1680)
      @team.members << p

      p = Member.create(
        iac_id: 784202, 
        given_name: 'Michael', 
        family_name: 'VanderMeulen')
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_mac80,
        category_value: 1375.70, total_possible: 1680)
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_youst,
        category_value: 1406.47, total_possible: 1680)
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_ntnls,
        category_value: 1312.10, total_possible: 1680)
      @team.members << p

      p = Member.create(
        iac_id: 921287,
        given_name: 'Alex', 
        family_name: 'Hunt')
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_youst,
        category_value: 1361.97, total_possible: 1680)
      @team.members << p

      p = Member.create(
        iac_id: 444844,
        given_name: 'Estin', 
        family_name: 'Johnson')
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_mac80,
        category_value: 1265.90, total_possible: 1680)
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_youst,
        category_value: 1403.33, total_possible: 1680)
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_ntnls,
        category_value: 1337.22, total_possible: 1680)
      @team.members << p

      @pilot_contests = pcrs.group_by { |pcr| pcr.pilot }
      @team.pc_results << pcrs
      @team.save
    end

    it 'computes team result' do
      ctr = CollegiateTeamComputer.new(@pilot_contests)
      r = ctr.compute_result
      expect(r.qualified).to be true
      expect(r.total).to eq 6298.77
      expect(r.total_possible).to eq 7440
      trio = r.combination.group_by { |pcr| pcr.pilot.iac_id }
      expect(trio.keys).to match [877212, 614888, 201845]
      expect(trio[877212][0].category_value).to eq 3345.26
      expect(trio[877212][0].total_possible).to eq 4080
      expect(trio[614888][0].category_value).to eq 1496.34
      expect(trio[614888][0].total_possible).to eq 1680
      expect(trio[201845][0].category_value).to eq 1457.17
      expect(trio[201845][0].total_possible).to eq 1680
    end

    context 'hc results' do
      before :context do
        @mills_hcr = PcResult.create(pilot: @pilot_mills,
          category: @spn,
          contest: @c_michg,
          hors_concours: true,
          category_value: 3500.00, total_possible: 4080)
      end
      it 'omits HC computing team' do
        @team.pc_results << @mills_hcr
        @team.save
        computer = CollegiateComputer.new(@year)
        computer.recompute_team
        @team.reload
        expect(@team.points).to eq 6298.77
      end
      it 'omits HC computing individual' do
        @mills.pc_results << @mills_hcr
        @mills.save
        computer = CollegiateIndividualComputer.new(@year)
        computer.recompute
        @mills.reload
        expect(@mills.points).to eq 9971.66
        expect(@mills.points_possible).to eq 12240
      end
    end
  end
end
