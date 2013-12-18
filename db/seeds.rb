require 'github_load'


# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Initial Load of Repos
#GithubLoad.load_org_companies
GithubLoad.load_repos
GithubLoad.load_all_prs

#GithubLoad.fix_users_without_companies