require 'spec_helper'

describe "repos/show" do
  before(:each) do
    @repo = assign(:repo, stub_model(Repo,
      :git_id => 1,
      :name => "Name",
      :full_name => "Full Name",
      :fork => false,
      :org => "Org"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Name/)
    rendered.should match(/Full Name/)
    rendered.should match(/false/)
    rendered.should match(/Org/)
  end
end
