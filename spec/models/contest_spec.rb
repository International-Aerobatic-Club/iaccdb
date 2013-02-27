require 'spec_helper'

describe Contest do
  it 'cleans the contest data on reset_to_base_attributes' do
    contest = Contest.new
    contest.save
    flight = contest.flights.create(:category => 'Unlimited', 
        :name => 'Known', :sequence => 1)
    c_result = contest.c_results.create
    failure = contest.failures.create
    fid = flight.id
    crid = c_result.id
    faid = failure.id
    Flight.find(fid).should_not be_nil
    CResult.find(crid).should_not be_nil
    Failure.find(faid).should_not be_nil
    contest.flights.should_not be_empty
    contest.c_results.should_not be_empty
    contest.failures.should_not be_empty
    contest.reset_to_base_attributes
    expect {Flight.find(fid)}.to raise_error(ActiveRecord::RecordNotFound)
    expect {CResult.find(crid)}.to raise_error(ActiveRecord::RecordNotFound)
    expect {Failure.find(faid)}.to raise_error(ActiveRecord::RecordNotFound)
    contest.flights.should be_empty
    contest.c_results.should be_empty
    contest.failures.should be_empty
  end
end
