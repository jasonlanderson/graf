require "load_steps/load_helpers"

describe LoadHelpers do
  #name = "Kalonji K. bankole"
  #it 'contains no initial?' do
  #	expect(LoadHelpers.format_name(name)).to equal("Kalonji Bankole")
  #end
  #
  #name = "kalonji BANKOLE"
  #it 'capitalized?' do
  #	expect LoadHelpers.format_name(name).to equal "Kalonji Bankole"
  #end

  company = "IBM Corporation"
 
  it 'merges similar companies' do
	expect(LoadHelpers.merge(company)).to match("IBM")
  end

end
