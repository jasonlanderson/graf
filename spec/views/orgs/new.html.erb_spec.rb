require 'spec_helper'

describe "orgs/new" do
  before(:each) do
    assign(:org, stub_model(Org,
      :git_id => 1,
      :login => "MyString",
      :name => "MyString",
      :type => ""
    ).as_new_record)
  end

  it "renders new org form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", orgs_path, "post" do
      assert_select "input#org_git_id[name=?]", "org[git_id]"
      assert_select "input#org_login[name=?]", "org[login]"
      assert_select "input#org_name[name=?]", "org[name]"
      assert_select "input#org_type[name=?]", "org[type]"
    end
  end
end
