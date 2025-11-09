describe 'hc_ranked', type: :model do
  COUNT = 8
  before :context do
    @contest = create(:contest)
    @category = Category.find_for_cat_aircat('advanced', 'P')
  end
  before :each do
    @pc_results = []
    (1..COUNT).each do |r|
      @pc_results << create(:pc_result, contest: @contest, category: @category,
        category_rank: r)
    end
  end
  it 'ranks with one hc pilot' do
    @pc_results[4].hc_no_reason.save!
    hc_results = PcResultM::HcRanked.computed_display_ranks(@pc_results)
    expect(hc_results.count).to eq COUNT
    expect(hc_results[0].display_rank).to eq '1'
    expect(hc_results[3].display_rank).to eq '4'
    expect(hc_results[4].display_rank).to eq 'HC'
    expect(hc_results[5].display_rank).to eq '5'
  end
  it 'ranks with one hc pilot tied' do
    @pc_results[4].hc_no_reason.save!
    @pc_results[5].category_rank = @pc_results[4].category_rank
    hc_results = PcResultM::HcRanked.computed_display_ranks(@pc_results)
    expect(hc_results.count).to eq COUNT
    expect(hc_results[4].display_rank).to eq 'HC'
    expect(hc_results[5].display_rank).to eq '5'
  end
  it 'ranks with one hc pilot, two after tied' do
    @pc_results[4].hc_no_reason.save!
    @pc_results[5].category_rank = @pc_results[6].category_rank
    hc_results = PcResultM::HcRanked.computed_display_ranks(@pc_results)
    expect(hc_results.count).to eq COUNT
    expect(hc_results[4].display_rank).to eq 'HC'
    expect(hc_results[5].display_rank).to eq '5'
    expect(hc_results[6].display_rank).to eq '5'
  end
  it 'ranks with two hc_pilots' do
    @pc_results[4].hc_no_reason.save!
    @pc_results[6].hc_no_reason.save!
    hc_results = PcResultM::HcRanked.computed_display_ranks(@pc_results)
    expect(hc_results.count).to eq COUNT
    expect(hc_results[4].display_rank).to eq 'HC'
    expect(hc_results[5].display_rank).to eq '5'
    expect(hc_results[6].display_rank).to eq 'HC'
    expect(hc_results[7].display_rank).to eq '6'
  end
  it 'ranks with hc_pilot first' do
    @pc_results[0].hc_no_reason.save!
    hc_results = PcResultM::HcRanked.computed_display_ranks(@pc_results)
    expect(hc_results.count).to eq COUNT
    expect(hc_results[0].display_rank).to eq 'HC'
    expect(hc_results[1].display_rank).to eq '1'
    expect(hc_results[2].display_rank).to eq '2'
    expect(hc_results[7].display_rank).to eq '7'
  end
  it 'ranks with hc_pilot last' do
    last = COUNT-1
    @pc_results[last].hc_no_reason.save!
    hc_results = PcResultM::HcRanked.computed_display_ranks(@pc_results)
    expect(hc_results.count).to eq COUNT
    expect(hc_results[0].display_rank).to eq '1'
    expect(hc_results[1].display_rank).to eq '2'
    expect(hc_results[2].display_rank).to eq '3'
    expect(hc_results[last].display_rank).to eq 'HC'
  end
end
