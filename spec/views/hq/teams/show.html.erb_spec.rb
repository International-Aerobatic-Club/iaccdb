require 'rails_helper'

RSpec.describe "hq/teams/show", :type => :view do
  before(:each) do
    @hq_team = assign(:hq_team, Hq::Team.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
