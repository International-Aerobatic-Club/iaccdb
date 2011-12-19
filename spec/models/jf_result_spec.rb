require 'spec_helper'
require 'iac/mannyParse'
require 'iac/mannyToDB'

describe JfResult do
  before(:all) do
    manny = Manny::MannyParse.new
    IO.foreach('spec/manny/Contest_300.txt') { |line| manny.processLine(line) }
    m2d = IAC::MannyToDB.new
    m2d.process_contest(manny, true)
    contest = Contest.first
    flight2 = contest.flights.first(:conditions => { 
      :category => 'Primary', :name => 'Free' })
    f_result = flight2.results.first
    j1 = Member.first(:conditions => {
      :family_name => 'Ramirez',
      :given_name => 'Laurie' })
    j2 = Member.first(:conditions => {
      :family_name => 'Flournoy',
      :given_name => 'Martin' })
    @jf_result1 = f_result.jf_results.first(:conditions => {
      :judge_id => j1 })
    @jf_result2 = f_result.jf_results.first(:conditions => {
      :judge_id => j2 })
  end
  it 'computes the Spearman rank coefficient for each judge of a flight' do
    @jf_result1.rho.should == 54
    @jf_result2.rho.should == 77
  end
  it 'computes the CIVA RI formula for each judge of a flight' do
    @jf_result1.ri.should == 4.39
    @jf_result2.ri.should == 3.74
  end
  it 'computes the Kendal tau for each judge of a flight' do
    @jf_result1.tau.should == 1.17
    @jf_result2.tau.should == 1.5
  end
  it 'computes the Gamma for each judge of a flight' do
    @jf_result1.gamma.should == 47
    @jf_result2.gamma.should == 60
  end
  it 'computes the standard correlation coefficient for each judge of a flight' do
    @jf_result1.cc.should == 91
    @jf_result2.cc.should == 96
  end
  it 'computes the number of minority zeros from each judge for a flight'
  it 'computes the number of minority grades from each judge for a flight'
  it 'counts the number of grades given by every judge for a flight'
  it 'counts the number of pilots graded by every judge for a flight'
end
