describe Judge, :type => :model do
  before :example do
    @jr_1 = create(:judge)
  end
  def check_judge_and_assist(jp, judge, assistant)
    expect(jp).to_not be nil
    expect(jp.judge_id).to eq judge.id
    expect(jp.assist_id).to eq assistant.id
  end
  context 'creates or locates judge pair with substitute judge' do
    before :example do
      @new_judge = create(:member)
    end
    it 'when substitute judge pair exists' do
      exist_jp = create(:judge, judge: @new_judge, assist: @jr_1.assist)
      check_judge_and_assist(exist_jp, @new_judge, @jr_1.assist)
      found_jp = @jr_1.find_or_create_with_substitute_judge(@new_judge.id)
      check_judge_and_assist(found_jp, @new_judge, @jr_1.assist)
      expect(found_jp.id).to eq exist_jp.id
    end
    it 'when new judge pair does not exist' do
      found_jp = @jr_1.find_or_create_with_substitute_judge(@new_judge.id)
      check_judge_and_assist(found_jp, @new_judge, @jr_1.assist)
    end
    it 'returns self if new judge id matches current' do
      found_jp = @jr_1.find_or_create_with_substitute_judge(@jr_1.judge.id)
      expect(found_jp).to_not be nil
      expect(found_jp.id).to eq @jr_1.id
    end
  end
  context 'creates or locates judge pair with substitute assistant' do
    before :example do
      @new_assistant = create(:member)
    end
    it 'when substitute judge pair exists' do
      exist_jp = create(:judge, assist: @new_assistant, judge: @jr_1.judge)
      check_judge_and_assist(exist_jp, @jr_1.judge, @new_assistant)
      found_jp = @jr_1.find_or_create_with_substitute_assistant(@new_assistant.id)
      check_judge_and_assist(found_jp, @jr_1.judge, @new_assistant)
      expect(found_jp.id).to eq exist_jp.id
    end
    it 'when new judge pair does not exist' do
      found_jp = @jr_1.find_or_create_with_substitute_assistant(@new_assistant.id)
      expect(found_jp).to_not be nil
      check_judge_and_assist(found_jp, @jr_1.judge, @new_assistant)
    end
    it 'returns self if new judge id matches current' do
      found_jp = @jr_1.find_or_create_with_substitute_assistant(@jr_1.assist.id)
      expect(found_jp).to_not be nil
      expect(found_jp.id).to eq @jr_1.id
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
