## App Tools

[Zendesk Apps Tools](http://rubygems.org/gems/zendesk_apps_tools) is a ruby gem that makes it easy to build Zendesk Apps. The gem allows allows an App developer to create, validate & test apps locally.


### How to use

**STEP 1**: Install 'zat' using [RubyGems](http://rubygems.org/gems/zendesk_apps_tools).

    $ gem install zendesk_apps_tools

**STEP 2**: Create a new app using 'zat'. Here's an example:

    $ zat new
    Enter this app author's name:
    John Smith
    Enter this app author's email:
    john@example.com
    Enter a name for this new app:
    Test App
    Enter a directory name to save the new app (will create the dir if it does not exist, default to current dir):
    /tmp/test-app
          create  /tmp/test-app
          create  /tmp/test-app/app.css
          create  /tmp/test-app/app.js
          create  /tmp/test-app/assets/logo-small.png
          create  /tmp/test-app/assets/logo.png
          create  /tmp/test-app/manifest.json
          create  /tmp/test-app/templates/layout.hdbs
          create  /tmp/test-app/translations/en.json

**STEP 3**: Work on the new app by editing/adding the files in /tmp/test-app folder.

**STEP 4**: Validate the app.

    $ zat validate --path /tmp/test-app

**STEP 5**: Preview the app.

To preview a local app, follow these steps:

1) Start zat server

    $ zat server --path /tmp/test-app

    [2013-01-10 16:54:48] INFO  WEBrick 1.3.1
    [2013-01-10 16:54:48] INFO  ruby 1.9.3 (2012-04-20) [x86_64-darwin12.0.0]
    == Sinatra/1.3.3 has taken the stage on 4567 for development with backup from WEBrick
    [2013-01-10 16:54:48] INFO  WEBrick::HTTPServer#start: pid=76568 port=4567

2) In your favorite browser, navigate to a ticket in New Zendesk. The URL should be something like https://subdomain.zendesk.com/agent/#/tickets/1

3) Edit the URL in the address bar to include a 'zat' parameter `?zat=true`, then reload the page.

The full url should look something like this: https://subdomain.zendesk.com/agent/?zat=true#/tickets/1

4) Reload the apps by clicking the 'Reload Apps' link. The local app will appear in the app panel.

(Note: if you are using Chrome, and you see a 'Shield' icon in the address bar, click that icon, and it says 'This page has insecure content', then click 'Load Anyway'. This is because the page is using https, but we are loading the local app using http.)

**STEP 6**: Package the app.

    $ zat package --path /tmp/test-app
    Enter a zendesk URL that you'd like to install the app (for example: 'http://abc.zendesk.com', default to 'http://support.zendesk.com'):

        validate  OK
         package  adding app.css
         package  adding app.js
         package  adding assets/logo-small.png
         package  adding assets/logo.png
         package  adding manifest.json
         package  adding templates/layout.hdbs
         package  adding translations/en.json
         package  created at /tmp/test-app/tmp/app-20130110164906.zip

Now you can [upload the created zip](http://developer.zendesk.com/documentation/apps/uploading.html).


### Features

#### Create a Zendesk App
Create a template for a Zendesk App.

    $ zat new

#### Validate an App
Run a suite of validations against your App:

    $ zat validate

This will run the same validations that run when an App is uploaded to the Zendesk App Market.

#### Preview the App
Run a http server to serve the App locally.

    $ zat server

#### Package the app
Create a zip file that you can [upload](http://developer.zendesk.com/documentation/apps/uploading.html).

    $ zat package

#### Clean tmp folder inside an App
Remove zip files in the tmp folder.

    $ zat clean