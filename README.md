## GRAF Overview
TODO

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