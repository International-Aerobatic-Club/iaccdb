describe Judge, :type => :model do
  before :example do
    @jr_1 = create(:judge)
    @scores = []
    3.times { @scores << create(:score, judge:@jr_1) }
    @pfj_results = []
    3.times { @pfj_results << create(:pfj_result, judge:@jr_1) }
    @jf_results = []
    3.times { @jf_results << create(:jf_result, judge:@jr_1) }
  end
  def check_judge_has_relations(j)
    @scores.each { |s| expect(s.reload.judge).to eq j }
    @pfj_results.each { |s| expect(s.reload.judge).to eq j }
    @jf_results.each { |s| expect(s.reload.judge).to eq j }
    expect(j.scores.count).to eq 3
    expect(j.pfj_results.count).to eq 3
    expect(j.jf_results.count).to eq 3
  end
  def check_original_judge_empty
    expect(@jr_1.scores.count).to eq 0
    expect(@jr_1.pfj_results.count).to eq 0
    expect(@jr_1.jf_results.count).to eq 0
  end
  it 'initializes judge associations' do
    check_judge_has_relations(@jr_1)
  end
  context 'merges two member judges' do
    it 'when new judge pair exists' do
      jr_2 = create(:judge, assist: @jr_1.assist)
      @jr_1.merge_judge(jr_2.judge.id)
      check_judge_has_relations(jr_2)
      check_original_judge_empty
    end
    it 'when new judge pair does not exist' do
      j_2 = create(:member)
      @jr_1.merge_judge(j_2.id)
      jr_2 = @scores[0].reload.judge
      expect(jr_2.judge).to eq j_2
      check_judge_has_relations(jr_2)
      check_original_judge_empty
    end
    it 'does nothing if new judge id matches current' do
      @jr_1.merge_judge(@jr_1.judge_id)
      check_judge_has_relations(@jr_1)
    end
  end
  context 'merges two member assistants' do
    it 'when new judge pair exists' do
      jr_2 = create(:judge, judge: @jr_1.judge)
      @jr_1.merge_assist(jr_2.assist_id)
      check_judge_has_relations(jr_2)
      check_original_judge_empty
    end
    it 'when new judge pair does not exists' do
      j_2 = create(:member)
      @jr_1.merge_assist(j_2.id)
      jr_2 = @scores[0].reload.judge
      expect(jr_2.assist).to eq j_2
      check_judge_has_relations(jr_2)
      check_original_judge_empty
    end
    it 'does nothing if new assist id matches current' do
      @jr_1.merge_assist(@jr_1.assist_id)
      check_judge_has_relations(@jr_1)
    end
  end
  context 'missing judge' do
    it 'always returns the same judge for missing judge pair' do
      judge_pair = Judge.missing_judge
      jpid = judge_pair.id
      3.times do 
        judge_pair = Judge.missing_judge
        expect(judge_pair.id).to eq jpid
      end
    end
    it 'always has the same missing member as missing judge pair judge' do
      judge_pair = Judge.missing_judge
      jid = judge_pair.judge.id
      3.times do 
        judge_pair = Judge.missing_judge
        expect(judge_pair.judge.id).to eq jid
      end
    end
    it 'always has nil as missing judge pair assistant' do
      3.times do 
        judge_pair = Judge.missing_judge
        expect(judge_pair.assist).to eq nil
      end
    end
  end
end
