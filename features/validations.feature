Feature: validations

  ZAT can run validations on your app locally before you upload it.

  Scenario: missing manifest.json
    Given an app directory
    When I run `zat validate`
    Then the output should contain "No manifest found!"

  Scenario: manifest.json that isn't JSON
    Given an app directory
    And a file named "manifest.json" with:
      """json
      { f\oo: 'Bar' }
      """
    When I run `zat validate`
    Then the output should contain "manifest.json is not proper JSON"

  Scenario: missing manifest keys
    Given an app directory
    And a file named "manifest.json" with:
      """json
      {}
      """
    When I run `zat validate`
    Then the output should contain "Missing keys in manifest:"

  Scenario: missing manifest keys, specify app dir
    Given an app directory
    And a file named "path/to/app/manifest.json" with:
      """json
      {}
      """
    When I run `zat validate path/to/app`
    Then the output should contain "Missing keys in manifest:"

  Scenario: missing app.js
    Given an app directory
    When I run `zat validate`
    Then the output should contain "No source found!"

  Scenario: app.js with invalid globals
    Given an app directory
    And a file named "app.js" with:
      """
      {
        events: {
          'app.activated': function() {
            jQuery('a').css('color', 'red');
          }
        }
      }
      """
    When I run `zat validate`
    Then the output should contain "JSHint errors"

  Scenario: valid app
    Given an app directory
    And a file named "manifest.json" with:
      """json
      {
        "author": { "name": "Foo", "email": "foo@example.com" },
        "default_locale": "pt"
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
