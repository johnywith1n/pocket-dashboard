pocket-dashboard
================

A Dashboard for [Pocket](http://getpocket.com/)

To run this app, you need a Pocket App Consumer Key. You can get one at (http://getpocket.com/developer/apps/new). Give the app the "Retrieve" permission and choose the "Web" platform. Once you create the app, create a file in the project directory called CONSUMER_KEY, and put the consumer key for your app in that file.

To run, go to the project directory and run:

``` 
npm install
``` 
then compile all coffeescript files with:

``` 
coffee -c .
``` 

and finally start the server with:

``` 
node app.js
```
