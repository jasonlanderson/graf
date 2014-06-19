require "db_utils"

describe DBUtils do
  it "can escape" do
    expect(DBUtils.esc("jason ' quote")).to match "jason \\' quote"
  end
end