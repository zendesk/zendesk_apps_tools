Feature: create a template for a new zendesk app

  Scenario: create a template for a new zendesk app by running 'zat new' command
    Given an app directory "tmp/aruba" exists
    When I run "zat new" command with the following details:
      | author name  | John Citizen      |
      | author email | john@example.com  |
      | app name     | John Test App     |
      | app dir      | tmp/aruba         |

    Then the app file "tmp/aruba/manifest.json" is created with:
    """
{
  "name": "John Test App",
  "author": {
    "name": "John Citizen",
    "email": "john@example.com"
  },
  "defaultLocale": "en",
  "private": true,
  "location": "ticket_sidebar",
  "version": "1.0",
  "frameworkVersion": "0.5"
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
  <span class="logo"/>
  <h3>{{setting "name"}}</h3>
</header>
<section data-main/>
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
    "description":  "Play the famous zen tunes in your help desk.",
    "name":         "Buddha Machine"
  }
}
"""
