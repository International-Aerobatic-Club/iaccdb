require 'rails_helper'

RSpec.describe "hq/collegiates/show", :type => :view do
  before(:each) do
    @hq_collegiate = assign(:hq_collegiate, Hq::Collegiate.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
