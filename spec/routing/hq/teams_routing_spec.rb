require "rails_helper"

RSpec.describe Hq::TeamsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/hq/teams").to route_to("hq/teams#index")
    end

    it "routes to #new" do
      expect(:get => "/hq/teams/new").to route_to("hq/teams#new")
    end

    it "routes to #show" do
      expect(:get => "/hq/teams/1").to route_to("hq/teams#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/hq/teams/1/edit").to route_to("hq/teams#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/hq/teams").to route_to("hq/teams#create")
    end

    it "routes to #update" do
      expect(:put => "/hq/teams/1").to route_to("hq/teams#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/hq/teams/1").to route_to("hq/teams#destroy", :id => "1")
    end

  end
end
