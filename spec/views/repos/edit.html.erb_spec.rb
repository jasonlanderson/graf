require 'spec_helper'

describe "repos/edit" do
  before(:each) do
    @repo = assign(:repo, stub_model(Repo,
      :git_id => 1,
      :name => "MyString",
      :full_name => "MyString",
      :fork => false,
      :org => "MyString"
    ))
  end

  it "renders the edit repo form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", repo_path(@repo), "post" do
      assert_select "input#repo_git_id[name=?]", "repo[git_id]"
      assert_select "input#repo_name[name=?]", "repo[name]"
      assert_select "input#repo_full_name[name=?]", "repo[full_name]"
      assert_select "input#repo_fork[name=?]", "repo[fork]"
      assert_select "input#repo_org[name=?]", "repo[org]"
    end
  end
end
