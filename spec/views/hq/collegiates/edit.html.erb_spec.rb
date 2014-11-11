require 'rails_helper'

RSpec.describe "hq/collegiates/edit", :type => :view do
  before(:each) do
    @hq_collegiate = assign(:hq_collegiate, Hq::Collegiate.create!())
  end

  it "renders the edit hq_collegiate form" do
    render

    assert_select "form[action=?][method=?]", hq_collegiate_path(@hq_collegiate), "post" do
    end
  end
end
