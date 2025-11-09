describe Score, type: :model do
  it 'saves missing_judge when saved with judge nil' do
    score = build :score
    score.judge = nil
    score.save
    expect(score.judge).to eq Judge.missing_judge
  end

  it 'has missing judge on retrieve with NULL judge' do
    score = create :score
    # bypass callbacks to put null judge_id in the score record
    score.update_column('judge_id', nil)
    expect(score.judge).to be_nil
    score = Score.find(score.id)
    expect(score.judge).to eq Judge.missing_judge
  end
end
