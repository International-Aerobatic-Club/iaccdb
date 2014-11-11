require 'rails_helper'

RSpec.describe "hq/collegiates/new", :type => :view do
  before(:each) do
    assign(:hq_collegiate, Hq::Collegiate.new())
  end

  it "renders new hq_collegiate form" do
    render

    assert_select "form[action=?][method=?]", hq_collegiates_path, "post" do
    end
  end
end
