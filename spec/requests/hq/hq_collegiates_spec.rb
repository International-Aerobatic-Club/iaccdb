require 'rails_helper'

RSpec.describe "Hq::Collegiates", :type => :request do
  describe "GET /hq_collegiates" do
    it "works! (now write some real specs)" do
      get hq_collegiates_path
      expect(response).to have_http_status(200)
    end
  end
end
