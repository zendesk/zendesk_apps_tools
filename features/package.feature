Feature: package

  ZAT can package up your app directory as a .zip file.

  Background:
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
    And a file named "translations/zh.json" with:
      """json
      {
        "hello": "你好"
      }
      """

  Scenario: package a directory
    When I run `zat package`
    Then the output should contain "adding manifest.json"
    And the output should contain "adding app.js"
    And the output should contain "adding translations/zh.json"
    And the output should contain "created at "
    And the exit status should be 0

  Scenario: repackage a directory
    When I run `zat package`
    And I overwrite "manifest.json" with:
      """json
      {
        "author": { "name": "Bar", "email": "bar@example.com" },
        "default_locale": "pt"
      }
      """
    And I run `zat package`
    Then the output should contain "adding manifest.json"
    And the exit status should be 0

  Scenario: repackage a directory with no changes
    When I run `zat package`
    And I run `zat package`
    Then the output should contain "Nothing changed"
    And the exit status should be 0
