Feature: create a template for a new zendesk app

  Scenario: Create a new app in an existing directory
    Given an app directory "tmp/aruba" exists
    And I move to the app directory
    When I run "zat new" command with the following details:
      | author name  | John Citizen      |
      | author email | john@example.com  |
      | author url   | http://myapp.com  |
      | app name     | John Test App     |
      | app dir      |                   |

   Then the app file "manifest.json" is created
   And I reset the working directory

   Scenario: create a template for a new zendesk app by running 'zat new' command
     Given an app directory "tmp/aruba" exists
     When I run "zat new" command with the following details:
       | author name  | John Citizen      |
       | author email | john@example.com  |
       | author url   | http://myapp.com  |
       | app name     | John Test App     |
       | app dir      | tmp/aruba         |

     Then the app file "tmp/aruba/manifest.json" is created with:
     """
 {
   "name": "John Test App",
   "author": {
     "name": "John Citizen",
     "email": "john@example.com",
     "url": "http://myapp.com"
   },
   "defaultLocale": "en",
   "private": true,
   "location": { "zendesk":
     { "ticket_sidebar": "_legacy" }
   },
   "version": "1.0",
   "frameworkVersion": "1.0"
 }
 """
     And the app file "tmp/aruba/app.js" is created with:
     """
 (function() {

   return {
     events: {
       'app.activated':'doSomething'
     },

     doSomething: function() {
     }
   };

 }());
 """
     And the app file "tmp/aruba/templates/layout.hdbs" is created with:
     """
 <header>
   <span class="logo"></span>
   <h3>{{setting "name"}}</h3>
 </header>
 <section data-main></section>
 <footer>
   <a href="mailto:{{author.email}}">
     {{author.name}}
   </a>
 </footer>
 """
     And the app file "tmp/aruba/translations/en.json" is created with:
     """
 {
   "app": {
     "package": "app_name",
     "description": {
       "value": "Play the famous zen tunes in your help desk.",
       "title": "app description"
     },
     "name": {
       "value": "Buddha Machine",
       "title": "app name"
     }
   },

   "loading": {
     "value": "Welcome to this Sample App",
     "title": "loading placeholder"
   },

   "fetch": {
     "done": {
       "value": "Good",
       "title": "fetch success"
     },
     "fail": {
       "value": "failed to fetch information from the server",
       "title": "fetch failure"
     }
   },

   "id": {
     "value": "ID",
     "title": "user id"
   },

   "email": {
     "value": "Email",
     "title": "user email"
   },

   "name": {
     "value": "Name",
     "title": "user name"
   },

   "role": {
     "value": "Role",
     "title": "user role"
   },

   "groups": {
     "value": "Groups",
     "title": "user groups"
   }
 }
 """

 Scenario: create a template for a new iframe only app by running 'zat new --iframe-only' command
   Given an app directory "tmp/aruba" exists
   And I move to the app directory
   When I run "zat new --iframe-only" command with the following details:
     | author name  | John Citizen      |
     | author email | john@example.com  |
     | author url   | http://myapp.com  |
     | app name     | John Test App     |
     | iframe uri   | assets/index.html |
     | app dir      | tmp/aruba         |

   Then the app file "tmp/aruba/manifest.json" is created with:
   """
{
 "name": "John Test App",
 "author": {
   "name": "John Citizen",
   "email": "john@example.com",
   "url": "http://myapp.com"
 },
 "defaultLocale": "en",
 "private": true,
 "location": { "zendesk":
   { "ticket_sidebar": "assets/index.html" }
 },
 "version": "1.0",
 "frameworkVersion": "1.0"
}
"""
