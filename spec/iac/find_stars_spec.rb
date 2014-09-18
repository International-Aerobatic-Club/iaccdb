module IAC
  describe FindStars do
    it 'counts hard zeros' do
      ctst = create(:contest, name: 'Test Find Stars')
      cat = create(:category, category: 'Sportsman', name: 'Sportsman Power')
      seq = create(:sequence, figure_count: 4, k_values: [20, 4, 15, 9])
      flt = create(:flight, category: cat, contest: ctst)
      pilot = create(:member)
      pf = create(:pilot_flight, sequence: seq, flight: flt, pilot: pilot)
      create(:score, values: [60, 65, Constants::HARD_ZERO, 70], pilot_flight: pf)
      create(:score, values: [55, 80, 70, 60], pilot_flight: pf)
      create(:score, values: [85, 95, 90, 90], pilot_flight: pf)
      flt2 = create(:flight, category: cat, contest: ctst, name: 'Free')
      pf = create(:pilot_flight, sequence: seq, flight: flt2, pilot: pilot)
      create(:score, values: [70, 100, Constants::HARD_ZERO, 80], pilot_flight: pf)
      create(:score, values: [75, 90, 80, 80], pilot_flight: pf)
      create(:score, values: [90, 90, 95, 90], pilot_flight: pf)
      cres = create(:c_result, contest: ctst, category: cat)
      pcres = create(:pc_result, c_result: cres, pilot: pilot)
      pcres.star_qualifying = true
      pcres.save
      FindStars.findStars(ctst)
      pcres.reload
      expect(pcres.star_qualifying).to be false
    end

    it 'finds star qualifying Sportsman flight' do
      ctst = create(:contest, name: 'Test Find Stars')
      cat = create(:category, category: 'Sportsman', name: 'Sportsman Power')
      seq = create(:sequence, figure_count: 4, k_values: [20, 4, 15, 9])
      flt = create(:flight, category: cat, contest: ctst)
      pilot = create(:member)
      pf = create(:pilot_flight, sequence: seq, flight: flt, pilot: pilot)
      create(:score, values: [60, 65, 55, 70], pilot_flight: pf)
      create(:score, values: [55, 80, 70, 60], pilot_flight: pf)
      create(:score, values: [85, 95, 90, 90], pilot_flight: pf)
      flt2 = create(:flight, category: cat, contest: ctst, name: 'Free')
      pf = create(:pilot_flight, sequence: seq, flight: flt2, pilot: pilot)
      create(:score, values: [70, 100, 55, 80], pilot_flight: pf)
      create(:score, values: [75, 90, 80, 80], pilot_flight: pf)
      create(:score, values: [90, 90, 95, 90], pilot_flight: pf)
      cres = create(:c_result, contest: ctst, category: cat)
      pcres = create(:pc_result, c_result: cres, pilot: pilot)
      FindStars.findStars(ctst)
      pcres.reload
      expect(pcres.star_qualifying).to be true
    end
  end
end
