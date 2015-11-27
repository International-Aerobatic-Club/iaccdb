module IAC
  describe CollegiateComputer do
    it 'computes team result' do
      pcrs = []
      c_ntnls = create(:contest, name: 'U.S. National Aerobatic Championships')
      c_mac80 = create(:contest, name: 'MAC80 : IAC Open West Championships')
      c_youst = create(:contest, name: 'Doug Youst Challenge')
      c_canam = create(:contest, name: 'Rocky Mountin Can-Am')
      c_michg = create(:contest, name: 'Michigan Aerobatic Open')
      pri = Category.create(category: 'primary', aircat: 'P',
        name: 'Primary Power', sequence: 1)
      spn = Category.create(category: 'sportsman', aircat: 'P',
        name: 'Sportsman Power', sequence: 2)
      adv = Category.create(category: 'advanced', aircat: 'P',
        name: 'Advanced Power', sequence: 3)
      pri_ntnls = CResult.create(contest_id: c_ntnls.id, category_id: pri.id)
      pri_mac80 = CResult.create(contest_id: c_mac80.id, category_id: pri.id)
      pri_youst = CResult.create(contest_id: c_youst.id, category_id: pri.id)
      spn_ntnls = CResult.create(contest_id: c_ntnls.id, category_id: spn.id)
      spn_mac80 = CResult.create(contest_id: c_mac80.id, category_id: spn.id)
      spn_youst = CResult.create(contest_id: c_youst.id, category_id: spn.id)
      spn_canam = CResult.create(contest_id: c_canam.id, category_id: spn.id)
      adv_ntnls = CResult.create(contest_id: c_ntnls.id, category_id: adv.id)
      adv_mac80 = CResult.create(contest_id: c_mac80.id, category_id: adv.id)
      adv_youst = CResult.create(contest_id: c_youst.id, category_id: adv.id)
      adv_canam = CResult.create(contest_id: c_canam.id, category_id: adv.id)
      adv_michg = CResult.create(contest_id: c_michg.id, category_id: adv.id)

      p = Member.create(
        iac_id: 877212, given_name: 'Patrick', 
        family_name: 'Mills')
      pcrs << PcResult.create(pilot: p,
        category: spn,
        contest: c_mac80,
        category_value: 3315.30, total_possible: 4080)
      pcrs << PcResult.create(pilot: p,
        category: spn,
        contest: c_canam,
        category_value: 3302.50, total_possible: 4080)
      pcrs << PcResult.create(pilot: p,
        category: spn,
        contest: c_youst,
        category_value: 3345.26, total_possible: 4080)
      pcrs << PcResult.create(pilot: p,
        category: spn,
        contest: c_ntnls,
        category_value: 3311.10, total_possible: 4080)

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
        contest: c_michg,
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

      p = Member.create(
        iac_id: 518914,
        given_name: 'Alexander', 
        family_name: 'Volberding')
      pcrs << PcResult.create(pilot: p,
        category: spn,
        contest: c_mac80,
        category_value: 2984.42, total_possible: 4080)
      pcrs << PcResult.create(pilot: p,
        category: spn,
        contest: c_youst,
        category_value: 3162.88, total_possible: 4080)
      pcrs << PcResult.create(pilot: p,
        category: spn,
        contest: c_ntnls,
        category_value: 3114.14, total_possible: 4080)

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

      p = Member.create(
        iac_id: 303704, 
        given_name: 'Deven', 
        family_name: 'Romain')
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_youst,
        category_value: 1412.67, total_possible: 1680)

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

      p = Member.create(
        iac_id: 921287,
        given_name: 'Alex', 
        family_name: 'Hunt')
      pcrs << PcResult.create(pilot: p,
        category: pri,
        contest: c_youst,
        category_value: 1361.97, total_possible: 1680)

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

      pilot_contests = pcrs.group_by { |pcr| pcr.pilot }
      ctr = CollegiateTeamComputer.new(pilot_contests)
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
  end
end
