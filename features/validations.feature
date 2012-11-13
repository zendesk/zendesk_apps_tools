Feature: validations

  ZAT can run validations on your app locally before you upload it.

  Scenario: missing manifest.json
    Given an app directory
    When I run `zat validate`
    Then the output should contain "Could not find manifest.json"
    And the exit status should not be 0

  Scenario: manifest.json that isn't JSON
    Given an app directory
    And a file named "manifest.json" with:
      """json
      { f\oo: 'Bar' }
      """
    When I run `zat validate`
    Then the output should contain "manifest is not proper JSON"
    And the exit status should not be 0

  Scenario: missing manifest keys
    Given an app directory
    And a file named "manifest.json" with:
      """json
      {}
      """
    When I run `zat validate`
    Then the output should contain "Missing required fields in manifest:"
    And the exit status should not be 0

  Scenario: missing manifest keys, specify app dir
    Given an app directory
    And a file named "path/to/app/manifest.json" with:
      """json
      {}
      """
    When I run `zat validate path/to/app`
    Then the output should contain "Missing required fields in manifest:"
    And the exit status should not be 0

  Scenario: missing app.js
    Given an app directory
    When I run `zat validate`
    Then the output should contain "Could not find app.js"
    And the exit status should not be 0

  Scenario: app.js with invalid globals
    Given an app directory
    And a file named "app.js" with:
      """
      (function() {
        return {
          events: {
            'app.activated': function() {
              jQuery('a').css('color', 'red');
            }
          }
        };
      }());
      """
    When I run `zat validate`
    Then the output should contain "JSHint error in app.js"
    And the exit status should not be 0

  Scenario: invalid translation JSON
    Given an app directory
    And a file named "translations/xy.json" with:
      """json
      {
        foo = "bar"
      }
      """
    When I run `zat validate`
    Then the output should contain "JSHint errors in translations/xy.json"
    And the exit status should not be 0

  Scenario: style tag in template
    Given an app directory
    And a file named "templates/foo.hdbs" with:
      """handlebars
      <style>
        .foo { color: green; }
      </style>
      <div class="foo">
        Hello, World
      </div>
      """
    When I run `zat validate`
    Then the output should contain "<style> tag in templates/foo.hdbs"
    And the exit status should not be 0

  Scenario: valid app
    Given an app directory
    And a file named "manifest.json" with:
      """json
      {
        "author": { "name": "Foo", "email": "foo@example.com" },
        "defaultLocale": "pt"
      }
      """
    And a file named "app.js" with:
      """javascript
      (function() {
        return {
          events: {
            'app.activated': 'appActivated'
          },
          appActivated: function() {
            services.notify('Activated!');
          }
        };
      }());
      """
    When I run `zat validate`
    Then the output should contain "OK"
    And the exit status should be 0
