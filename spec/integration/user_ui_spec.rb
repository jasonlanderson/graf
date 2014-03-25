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