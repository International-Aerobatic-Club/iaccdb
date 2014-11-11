require "rails_helper"

RSpec.describe Hq::CollegiatesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/hq/collegiates").to route_to("hq/collegiates#index")
    end

    it "routes to #new" do
      expect(:get => "/hq/collegiates/new").to route_to("hq/collegiates#new")
    end

    it "routes to #show" do
      expect(:get => "/hq/collegiates/1").to route_to("hq/collegiates#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/hq/collegiates/1/edit").to route_to("hq/collegiates#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/hq/collegiates").to route_to("hq/collegiates#create")
    end

    it "routes to #update" do
      expect(:put => "/hq/collegiates/1").to route_to("hq/collegiates#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/hq/collegiates/1").to route_to("hq/collegiates#destroy", :id => "1")
    end

  end
end
