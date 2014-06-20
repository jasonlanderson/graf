## Welcome to GRAF
GitHub Repository Analytics with Filtering (GRAF) is a web service that has the ability to collect and visually represent useful statistics on various Github repositories. At the moment, this application is only collecting data on repositories hosted by the "CloudFoundry" Github organization. We plan to expand this application to collect data on repositories from other organizations (Openstack, Openshift, etc.) in the near future.

These statistics are collected through the Github API. We use the API's functions to gather information on every "Pull Request" that has been contributed to the CloudFoundry repositories. Once this data has been successfully collected and stored into our database, our application allows the user to generate figures that are customized by timeframe, repository, company, etc.

Company affiliation is determined by polling each Github user's profile. If a user does not have an affliated company listed on their profile, the application then checks to see whether the user is a member of any corporate Github organizations. If they are not, the user is assumed to be independent.


## Statistics Available
These are the available metrics through the Analytics page.

Metrics:
 * Pull Requests
 * Avg Days Pull Request is Open
 * Percent Merged of Pull Requests
 * Commit

Group By / Filters:
 * Org
 * Month
 * Quarter
 * Year
 * State
 * Repo
 * Company
 * User Name
 * Login Name


Additionally Start Date and End Date is 


Charts
- PRs by User
- PRs by Company

Tables
- PRs by User
- PRs by Company

Single Statistics
- Avg days to merge a PR
- Avg concurrent PR

## GRAF Overview
TODO

## Deploying on BlueMix
From the app's root directory do a push (see following command) and create an mysql db service.

   cf push -c 'bundle exec rake db:create db:migrate' graf

This command will fail but will setup your database.  Now delete your application using but do NOT delete your orphan database

   cf delete graf

Now do another push and bind to the mysql database you created in the first push:

   cf push graf

Your app should now be up and running. 