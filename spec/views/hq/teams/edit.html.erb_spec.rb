require 'rails_helper'

RSpec.describe "hq/teams/edit", :type => :view do
  before(:each) do
    @hq_team = assign(:hq_team, Hq::Team.create!())
  end

  it "renders the edit hq_team form" do
    render

    assert_select "form[action=?][method=?]", hq_team_path(@hq_team), "post" do
    end
  end
end
