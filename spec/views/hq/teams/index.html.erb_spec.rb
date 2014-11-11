require 'rails_helper'

RSpec.describe "hq/teams/index", :type => :view do
  before(:each) do
    assign(:hq_teams, [
      Hq::Team.create!(),
      Hq::Team.create!()
    ])
  end

  it "renders a list of hq/teams" do
    render
  end
end
