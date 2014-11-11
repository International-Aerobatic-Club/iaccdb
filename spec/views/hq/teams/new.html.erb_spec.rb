require 'rails_helper'

RSpec.describe "hq/teams/new", :type => :view do
  before(:each) do
    assign(:hq_team, Hq::Team.new())
  end

  it "renders new hq_team form" do
    render

    assert_select "form[action=?][method=?]", hq_teams_path, "post" do
    end
  end
end
