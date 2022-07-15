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
     "ticket_sidebar": {
       "url": "assets/iframe.html",
       "flexible": true
     }
   }
 },
 "version": "1.0",
 "frameworkVersion": "2.0"
}
   """
   And I reset the working directory
