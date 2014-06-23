## Welcome to GRAF
GitHub Repository Analytics with Filtering (GRAF) is a web application that has the ability to collect and visually represent useful statistics on various GitHub repositories.


## How it works?
GRAF collects and stores GitHub information in its local data warehouse using a GitHub API wrapper called Octokit. Through Octokit, GRAF gathers information on every *Pull Request* and *Commit* for the selected repositories. Once this data has been successfully collected, our application allows the user to generate figures that are customized by timeframe, repository, company, etc.

Company affiliation is determined by querying each GitHub user's profile. If a user does not have an affliated company listed on their profile, the application then checks to see whether the user is a member of any corporate Github organizations. If they are not, the user email is used to determine company affiliation.

## What statistics are available?
These are the available metrics and options through the Analytics page:

**Metrics**
* Commits
* Pull requests
* Avgerage number of days a pull request is open
* Percent of pull requests merged

**Views**
 * Pie Chart
 * Bar Chart
 * Line Chart
 * Table

**Group By / Filters**
 * Org
 * Month
 * Quarter
 * Year
 * State
 * Repo
 * Company
 * User Name
 * Login Name

Additionally start and end date filters are available.



## Deploying a GRAF instance on IBM's [BlueMix]
From the app's root directory do a push (see following command) and create an mysql db service.

```sh
cf push -c 'bundle exec rake db:create db:migrate' graf
```
   
This command will fail but will setup your database.  Now delete your application using but do NOT delete your orphan database
 
 ```sh
 cf delete graf
 ```

Now do another push and bind to the mysql database you created in the first push:

 ```sh
 cf push graf
 ```

Your app should now be up and running.

## Initialing the data
1. Modify the "config/graf/orgs.json" JSON file to select the organizations to load.
1. Open GRAF's /login page in a browser and enter a username / password.
1. Begin an initial load by going to /load and click the "Start Load" button
1. Once the load is complete, the user can view the data on the /analytics and /report page

## Updating a GRAF instance on [BlueMix]
```sh
cf delete graf
cf create-service mysql 300 graf-db
cf push graf
http://graf.stage1.ng.bluemix.net/info
cf delete graf
cf push -c 'bundle exec rake db:create db:migrate' graf
cf delete graf
cf push graf
cf push graf
```

## Setting up GitHub API access
Set up a Github Oauth token:
1. Login to your github account at https://github.com/login
1. Go to Github's Settings page at https://github.com/settings/applications
1. Register an application (https://github.com/settings/applications/new) to get a Client ID and a Client Secret
1. Generate a token (https://github.com/settings/tokens/new)
1. Place the Client ID, Client Secret, and Access token into the settings.json file, which is located in the root directory (graf/config/graf/settings.json) 


[BlueMix]:http://bluemix.net