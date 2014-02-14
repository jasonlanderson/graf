require "spec_helper"

describe OrgsController do
  describe "routing" do

    it "routes to #index" do
      get("/orgs").should route_to("orgs#index")
    end

    it "routes to #new" do
      get("/orgs/new").should route_to("orgs#new")
    end

    it "routes to #show" do
      get("/orgs/1").should route_to("orgs#show", :id => "1")
    end

    it "routes to #edit" do
      get("/orgs/1/edit").should route_to("orgs#edit", :id => "1")
    end

    it "routes to #create" do
      post("/orgs").should route_to("orgs#create")
    end

    it "routes to #update" do
      put("/orgs/1").should route_to("orgs#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/orgs/1").should route_to("orgs#destroy", :id => "1")
    end

  end
end
