require 'spec_helper'

describe "orgs/index" do
  before(:each) do
    assign(:orgs, [
      stub_model(Org,
        :git_id => 1,
        :login => "Login",
        :name => "Name",
        :type => "Type"
      ),
      stub_model(Org,
        :git_id => 1,
        :login => "Login",
        :name => "Name",
        :type => "Type"
      )
    ])
  end

  it "renders a list of orgs" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Login".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
  end
end
