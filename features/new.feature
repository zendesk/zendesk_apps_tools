Feature: create a template for a new zendesk app

  Scenario: Create a new app in an existing directory
    Given an app directory "tmp/aruba" exists
    And I move to the app directory
    When I run "zat new" command with the following details:
      | author name  | John Citizen      |
      | author email | john@example.com  |
      | author url   | http://myapp.com  |
      | app name     | John Test App     |
      | iframe uri   | assets/iframe.html |
      | app dir      |                   |

   Then the app file "manifest.json" is created
   And I reset the working directory

  Scenario: create a template for a new zendesk app by running 'zat new --v1' command
    Given an app directory "tmp/aruba" exists
    When I run "zat new --v1" command with the following details:
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
   "location":["ticket_sidebar"],
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
      "short_description": "Play the famous zen tunes in your help desk.",
      "long_description": "Play the famous zen tunes in your help desk and \n listen to the beats it has to offer.",
      "installation_instructions": "Simply click install."
   },
   "loading": "Welcome to this Sample App",
   "fetch": {
     "done": "Good",
     "fail": "failed to fetch information from the server"
   },
   "id": "ID",
   "email": "Email",
   "name": "Name",
   "role": "Role",
   "groups": "Groups"
 }
    """

  Scenario: create a template for a new iframe only app by running 'zat new' command
    Given an app directory "tmp/aruba" exists
    And I move to the app directory
    When I run "zat new" command with the following details:
      | author name  | John Citizen      |
      | author email | john@example.com  |
      | author url   | http://myapp.com  |
      | app name     | John Test App     |
      | iframe uri   | assets/iframe.html |
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
 "location": {
   "support": {
     "ticket_sidebar": "assets/iframe.html"
   }
 },
 "version": "1.0",
 "frameworkVersion": "2.0"
}
   """
   And I reset the working directory
