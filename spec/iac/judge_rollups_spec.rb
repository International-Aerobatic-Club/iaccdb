RSpec.describe IAC::JudgeRollups do
  before :context do
    @year = 2012
    @c1 = create(:contest, year: @year)
    @c2 = create(:contest, year: @year)
    @pri = Category.where(category: 'primary', aircat: 'P').first
    @spn = Category.where(category: 'sportsman', aircat: 'P').first
    @imd = Category.where(category: 'intermediate', aircat: 'P').first
    @adv = Category.where(category: 'advanced', aircat: 'P').first
    @j1 = create(:member)
    @j2 = create(:member)
    # J1  P S I
    # C1  3 5
    # C2  2 7 9
    create(:jc_result, contest: @c1, category: @pri, judge: @j1, pilot_count: 3)
    create(:jc_result, contest: @c2, category: @pri, judge: @j1, pilot_count: 2)
    create(:jc_result, contest: @c1, category: @spn, judge: @j1, pilot_count: 5)
    create(:jc_result, contest: @c2, category: @spn, judge: @j1, pilot_count: 7)
    create(:jc_result, contest: @c2, category: @imd, judge: @j1, pilot_count: 9)
    # J2 P x I A
    # C1 3   4 8
    # C2 2     3
    create(:jc_result, contest: @c1, category: @pri, judge: @j2, pilot_count: 3)
    create(:jc_result, contest: @c2, category: @pri, judge: @j2, pilot_count: 2)
    create(:jc_result, contest: @c1, category: @imd, judge: @j2, pilot_count: 4)
    create(:jc_result, contest: @c1, category: @adv, judge: @j2, pilot_count: 8)
    create(:jc_result, contest: @c2, category: @adv, judge: @j2, pilot_count: 3)
    IAC::JudgeRollups.compute_jy_results(@year)
  end
  it 'computes the set of JyResult' do
    expect(JyResult.count).to eq(6)
  end
  context 'primary' do
    it 'computes totals' do
      pri_r = JyResult.where(category: @pri)
      expect(pri_r.count).to eq(2)
    end
    it 'computes first judge totals' do
      pri_r = JyResult.where(category: @pri, judge: @j1)
      expect(pri_r.count).to eq(1)
      expect(pri_r.first.pilot_count).to eq(5)
    end
    it 'computes second judge totals' do
      pri_r = JyResult.where(category: @pri, judge: @j2)
      expect(pri_r.count).to eq(1)
      expect(pri_r.first.pilot_count).to eq(5)
    end
  end
  context 'sportsman' do
    it 'computes totals' do
      spn_r = JyResult.where(category: @spn)
      expect(spn_r.count).to eq(1)
    end
    it 'computes first judge totals' do
      spn_r = JyResult.where(category: @spn, judge: @j1)
      expect(spn_r.count).to eq(1)
      expect(spn_r.first.pilot_count).to eq(12)
    end
    it 'has no second judge totals' do
      spn_r = JyResult.where(category: @spn, judge: @j2)
      expect(spn_r.count).to eq(0)
    end
  end
  context 'intermediate' do
    it 'computes totals' do
      imd_r = JyResult.where(category: @imd)
      expect(imd_r.count).to eq(2)
    end
    it 'computes first judge totals' do
      imd_r = JyResult.where(category: @imd, judge: @j1)
      expect(imd_r.count).to eq(1)
      expect(imd_r.first.pilot_count).to eq(9)
    end
    it 'computes second judge totals' do
      imd_r = JyResult.where(category: @imd, judge: @j2)
      expect(imd_r.count).to eq(1)
      expect(imd_r.first.pilot_count).to eq(4)
    end
  end
  context 'advanced' do
    it 'computes totals' do
      adv_r = JyResult.where(category: @adv)
      expect(adv_r.count).to eq(1)
    end
    it 'has no first judge totals' do
      adv_r = JyResult.where(category: @adv, judge: @j1)
      expect(adv_r.count).to eq(0)
    end
    it 'computes second judge totals' do
      adv_r = JyResult.where(category: @adv, judge: @j2)
      expect(adv_r.count).to eq(1)
      expect(adv_r.first.pilot_count).to eq(11)
    end
  end
  context 'with changes' do
    before :context do
      # J1  P S I
      # C1  3 4
      # C2  2 6 x
      jcr = JcResult.where(contest: @c1, category: @spn, judge: @j1).first
      jcr.pilot_count = 4
      jcr.save
      jcr = JcResult.where(contest: @c2, category: @spn, judge: @j1).first
      jcr.pilot_count = 6
      jcr.save
      jcr = JcResult.where(contest: @c2, category: @imd, judge: @j1).first
      jcr.destroy
      # J2 P S I A
      # C1 3 4 4 8
      # C2 2 6   3
      create(:jc_result, contest: @c1, category: @spn, judge: @j2, pilot_count: 4)
      create(:jc_result, contest: @c2, category: @spn, judge: @j2, pilot_count: 6)
      IAC::JudgeRollups.compute_jy_results(@year)
    end
    it 'recomputes the set of JyResult' do
      expect(JyResult.count).to eq(6)
    end
    context 'sportsman' do
      it 'computes totals' do
        spn_r = JyResult.where(category: @spn)
        expect(spn_r.count).to eq(2)
      end
      it 'computes first judge totals' do
        spn_r = JyResult.where(category: @spn, judge: @j1)
        expect(spn_r.count).to eq(1)
        expect(spn_r.first.pilot_count).to eq(10)
      end
      it 'computes second judge totals' do
        spn_r = JyResult.where(category: @spn, judge: @j2)
        expect(spn_r.count).to eq(1)
        expect(spn_r.first.pilot_count).to eq(10)
      end
    end
    context 'intermediate' do
      it 'computes totals' do
        imd_r = JyResult.where(category: @imd)
        expect(imd_r.count).to eq(1)
      end
      it 'has no first judge totals' do
        imd_r = JyResult.where(category: @imd, judge: @j1)
        expect(imd_r.count).to eq(0)
      end
      it 'computes second judge totals' do
        imd_r = JyResult.where(category: @imd, judge: @j2)
        expect(imd_r.count).to eq(1)
        expect(imd_r.first.pilot_count).to eq(4)
      end
    end
  end
end
