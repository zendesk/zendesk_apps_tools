## Zendesk Apps Tools

Tools to help you develop Zendesk Apps. For more documentation about Zendesk Apps, please see [http://developer.zendesk.com/](http://developer.zendesk.com/).

## How to use

STEP 1: Install 'zat' using RubyGems.

    $ gem install zendesk_apps_tools

STEP 2: Create a new app using 'zat'. Here's an example:

    $ zat new
    Enter this app author's name:
    John Smith
    Enter this app author's email:
    john@example.com
    Enter a name for this new app:
    Test App
    Enter a directory name to save the new app (will create the dir if it dose not exist, default to current dir):
    /tmp/test-app
          create  /tmp/test-app
          create  /tmp/test-app/app.css
          create  /tmp/test-app/app.js
          create  /tmp/test-app/assets/logo-small.png
          create  /tmp/test-app/assets/logo.png
          create  /tmp/test-app/manifest.json
          create  /tmp/test-app/templates/layout.hdbs
          create  /tmp/test-app/translations/en.json

STEP 3: Work on the new app by editing/adding the files in /tmp/test-app folder.

STEP 4: Validate the app.

    $ zat validate --path /tmp/test-app

STEP 5: Preview the app.

To preview a local app, follow these steps:

1) Start zat server

    $ zat server --path /tmp/test-app

    [2013-01-10 16:54:48] INFO  WEBrick 1.3.1
    [2013-01-10 16:54:48] INFO  ruby 1.9.3 (2012-04-20) [x86_64-darwin12.0.0]
    == Sinatra/1.3.3 has taken the stage on 4567 for development with backup from WEBrick
    [2013-01-10 16:54:48] INFO  WEBrick::HTTPServer#start: pid=76568 port=4567

2) Using browser to open one ticket from your zendesk account, the URL showing in the browser address bar will look like this: https://xxx.zendesk.com/agent/#/tickets/1

3) Edit the URL in the address bar to include a 'zat' parameter, like this: https://xxx.zendesk.com/agent/?zat=http://localhost:4567/app.js#/tickets/1, then reload the page.
The value of 'zat' is the web address to serve the app locally. The port number should match the 'zat server' port number from previous step.

4) Reload the app by clicking on the 'APPS' button on the page, then clicking the 'Reload Apps' link. The local app will appear in the app panel.
(Note: if you are using Chrome, and you see a 'Shield' icon in the address bar, click that icon, and it says 'This page has insecure content', then click 'Load Anyway'. This is because the page is using https, but we are loading the local app using http.)

STEP 5: Package the app.

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

Now you can upload this new app /tmp/test-app/tmp/app-20130110164906.zip into zendesk App Market by using zendesk agent web portal.

You can get some zat help info by running the help command, for example:

    $ zat help
    Tasks:
      zat clean        # Remove app packages in temp folder
      zat help [TASK]  # Describe available tasks or one specific task
      zat new          # Generate a new app
      zat package      # Package your app
      zat server       # Run a http server to serve the local app
      zat validate     # Validate your app

    $ zat help package
    Usage:
      zat package

    Options:
      [--path=PATH]
                     # Default: ./

## Features

### Create a new zendesk app
Create a template for a new zendesk app

    $ zat new

### Validate the app
Run a suite of validations against your app:

    $ zat validate

This will check the following:

 * presence of `app.js` and `manifest.json`
 * JSHint on `app.js`
 * Syntax check on `manifest.json`
 * Presence of required properties in `manifest.json`
 * No `<style>` tags in templates

### Preview the app
Run a http server to serve the app to Zendesk app panel locally.

    $ zat server

### Package the app
Package an app directory into a zip file that you will upload to Zendesk.

    $ zat package

### Clean tmp folder inside the zendesk app
Remove zip files in the tmp folder inside the the zendesk app

    $ zat clean

## Contribution

## Supported Ruby Versions

Tested with Ruby 1.8.7 and 1.9.3

## License


## Support

