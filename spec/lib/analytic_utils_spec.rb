require "analytic_utils"

describe AnalyticUtils do

  # describe "top_x_with_rollup" do

  #   before :each do
  #     @test_hash = [{"login"=>"user1", "calculated_value"=>30},
  #       {"login"=>"user2", "calculated_value"=>3},
  #       {"login"=>"user3", "calculated_value"=>100},
  #       {"login"=>"user4", "calculated_value"=>1},
  #       {"login"=>"user5", "calculated_value"=>10}]
  #   end

  #   it "can rollup values after the top x" do
  #     resultFromFxn = AnalyticUtils.top_x_with_rollup(@test_hash, "login", "calculated_value", 3, "others", ROLLUP_METHOD::SUM)

  #     result = [{"login"=>"user3", "calculated_value"=>100},
  #       {"login"=>"user1", "calculated_value"=>30},
  #       {"login"=>"user5", "calculated_value"=>10},
  #       {"login"=>"others", "calculated_value"=>4}]

  #     expect(resultFromFxn).to match_array(result)

  #     resultFromFxn = AnalyticUtils.top_x_with_rollup(@test_hash, "login", "calculated_value", 1, "others", ROLLUP_METHOD::SUM)

  #     result = [{"login"=>"user3", "calculated_value"=>100},
  #       {"login"=>"others", "calculated_value"=>44}]

  #     expect(resultFromFxn).to match_array(result)
  #   end

  # 	it "will not break if top_x_count > array length" do
  # 	resultFromFxn = AnalyticUtils.top_x_with_rollup(@test_hash, "login", "calculated_value", 10, "others", ROLLUP_METHOD::SUM)
  #     expect(resultFromFxn).to match_array(@test_hash)
  # 	end

  # 	it "will not break if top_x_count = array length" do
  # 	resultFromFxn = AnalyticUtils.top_x_with_rollup(@test_hash, "login", "calculated_value", 5, "others", ROLLUP_METHOD::SUM)
  #     expect(resultFromFxn).to match_array(@test_hash)
  # 	end

  #   it "will not break if top_x_count == 0" do
  #     resultFromFxn = AnalyticUtils.top_x_with_rollup(@test_hash, "login", "calculated_value", 0, "others", ROLLUP_METHOD::SUM)

  #     result = [{"login"=>"others", "calculated_value"=>144}]

  #     expect(resultFromFxn).to match_array(result)
  #   end

  #   it "will not break if top_x_count < 0" do
  #     resultFromFxn = AnalyticUtils.top_x_with_rollup(@test_hash, "login", "calculated_value", -3, "others", ROLLUP_METHOD::SUM)

  #     result = [{"login"=>"others", "calculated_value"=>144}]

  #     expect(resultFromFxn).to match_array(result)
  #   end
  # end

  # TODO: Find where to put this in SpecHelper
  def remove_whitespace(input)
    input.gsub!(/\s+/, "")
  end

  describe "#get_state_criteria_clause" do
    it "can filter for all states" do
      states = ["open", "merged", "closed"]
      results = AnalyticUtils.get_state_criteria_clause(states)
      expect(remove_whitespace(results)).to include remove_whitespace("((pr.state = 'open') OR (pr.date_merged IS NOT NULL) OR (pr.state = 'closed' AND pr.date_merged IS NULL))")
    end

    it "can filter for only open" do
      states = ["open"]
      results = AnalyticUtils.get_state_criteria_clause(states)
      expect(remove_whitespace(results)).to include remove_whitespace("((pr.state = 'open'))")
    end

    it "can filter for only merged" do
      states = ["merged"]
      results = AnalyticUtils.get_state_criteria_clause(states)
      expect(remove_whitespace(results)).to include remove_whitespace("((pr.date_merged IS NOT NULL))")
    end

    it "can filter for only closed" do
      states = ["closed"]
      results = AnalyticUtils.get_state_criteria_clause(states)
      expect(remove_whitespace(results)).to include remove_whitespace("((pr.state = 'closed' AND pr.date_merged IS NULL))")
    end


    it "can filter for only open or merged" do
      states = ["open", "merged"]
      results = AnalyticUtils.get_state_criteria_clause(states)
      expect(remove_whitespace(results)).to include remove_whitespace("((pr.state = 'open') OR (pr.date_merged IS NOT NULL))")
    end

    it "can filter for only open or closed" do
      states = ["open", "closed"]
      results = AnalyticUtils.get_state_criteria_clause(states)
      expect(remove_whitespace(results)).to include remove_whitespace("((pr.state = 'open') OR (pr.state = 'closed' AND pr.date_merged IS NULL)")
    end

    it "can filter for only merged or closed" do
      states = ["merged", "closed"]
      results = AnalyticUtils.get_state_criteria_clause(states)
      expect(remove_whitespace(results)).to include remove_whitespace("((pr.date_merged IS NOT NULL) OR (pr.state = 'closed' AND pr.date_merged IS NULL)")
    end
  end

  describe "get_state_stats" do

    before :each do
      @test_data = [
        {"date_opened"=>Time.now, "date_closed"=>Time.now, "date_merged"=>nil},
        {"date_opened"=>Time.now, "date_closed"=>nil, "date_merged"=>nil},
        {"date_opened"=>Time.now, "date_closed"=>Time.now, "date_merged"=>nil},
        {"date_opened"=>Time.now, "date_closed"=>Time.now, "date_merged"=>Time.now}]
    end

    it "can calculate stats" do
      results = AnalyticUtils.get_state_stats(@test_data)
      expect(results[:total]).to equal 4
      expect(results[:open]).to equal 1
      expect(results[:closed]).to equal 2
      expect(results[:merged]).to equal 1
    end
  end
end