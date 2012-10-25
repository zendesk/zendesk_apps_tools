Feature: validations

  ZAT can run validations on your app locally before you upload it.

  Scenario: missing manifest.json
    Given an app directory
    When I run `zat validate`
    Then the output should contain "No manifest found!"

  Scenario: missing manifest keys
    Given an app directory
    And the file "manifest.json" with:
      """json
      {}
      """
    When I run `zat validate`
    Then the output should contain "Missing keys in manifest:"

  Scenario: missing manifest keys, specify app dir
    Given an app directory
    And the file "path/to/app/manifest.json" with:
      """json
      {}
      """
    When I run `zat validate path/to/app`
    Then the output should contain "Missing keys in manifest:"

  Scenario: missing app.js
    Given an app directory
    And the file "manifest.json" with:
      """json
      {
        "author": { "name": "Foo", "email": "foo@example.com" },
        "default_locale": "pt"
      }
      """
    When I run `zat validate`
    Then the output should contain "No source found!"
