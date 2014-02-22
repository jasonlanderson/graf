require 'spec_helper'

describe "orgs/edit" do
  before(:each) do
    @org = assign(:org, stub_model(Org,
      :git_id => 1,
      :login => "MyString",
      :name => "MyString",
      :type => ""
    ))
  end

  it "renders the edit org form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", org_path(@org), "post" do
      assert_select "input#org_git_id[name=?]", "org[git_id]"
      assert_select "input#org_login[name=?]", "org[login]"
      assert_select "input#org_name[name=?]", "org[name]"
      assert_select "input#org_type[name=?]", "org[type]"
    end
  end
end
