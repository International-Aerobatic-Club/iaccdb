require 'rails_helper'

RSpec.describe "hq/collegiates/index", :type => :view do
  before(:each) do
    assign(:hq_collegiates, [
      Hq::Collegiate.create!(),
      Hq::Collegiate.create!()
    ])
  end

  it "renders a list of hq/collegiates" do
    render
  end
end
