require 'spec_helper'

Capybara.default_driver = :selenium
#Capybara.default_wait_time = 10
#Capybara.default_driver = :webkit

feature "Pages are accessible via links" do
  scenario "User can access the main page" do
    visit root_path
    expect(page).to have_title "GRAF"
    expect(page).to have_content("GitHub Repository Analytics with Filtering")
  end

  scenario "User can access the Reports page" do
    visit root_path
    click_link "Reports"
    expect(URI.parse(current_url).path).to eq('/report')
  end
end

feature "Restricting Graf View As Types" do
  xscenario "User changes mertic to be avg days open and can only select bar and line" do
    pending("Need to figure out how to reference jquery multiselect values")
    #visit root_path
    #find(:xpath, '//*[@id="view_type"]')
    #find(:css, "#rollup[value='5']").set(true)
    #puts find(:css, "#metric_filter[value='avg_days_open']")
    #expect(page).to have_content("GRAF")
  end

  xscenario "User changes to commits" do
    pending("Need to figure out how to reference jquery multiselect values")
    #visit root_path
    #find(:xpath, '//*[@id="view_type"]')
    #find(:css, "#rollup[value='5']").set(true)
    #puts find(:css, "#metric_filter[value='avg_days_open']")
    #expect(page).to have_content("GRAF")
  end
end

feature "Restricting Group By For Metrics" do
  xscenario "When a user selects commits, state should no longer be a selectable group by" do
  end

  xscenario "When a user selects non-commits, state should be a selectable group by" do
  end
end

feature "Restricting Filters For Metrics" do
  xscenario "When a user selects commits, state should no longer be a selectable filter" do
  end

  xscenario "When a user selects non-commits, state should be a selectable filter" do
  end
end

feature "Clearing search criteria" do
  xscenario "Clearing search criteria with no search criteria selected" do
    # Run clear search criteria

    # Check that all search fields are now cleared
  end

  xscenario "Clearing search criteria with search criteria selected" do
    # Add in some seearch criteria

    # Run clear search criteria

    # Check that all search fields are now cleared
  end
end

feature "Download CSV File" do
  xscenario "Clicking download CSV file will download the file" do
  end
end

feature "Changing Chart View" do
  xscenario "A user can change the chart view" do
  end
end