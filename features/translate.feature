Feature: Translate app strings
  As a Zendesk admin
  To enable many languages
  I want to be able to map between json and yaml

  Scenario: Attempt to generate invalid package name
    Given an app is created in directory "tmp/aruba"
    When I run "cd tmp/aruba && zat translate create" command with the following details:
      | package name | This is wrong |
    Then the command output should contain "Invalid package name, try again:"

  Scenario: Generate template yaml from en.json
    Given an app is created in directory "tmp/aruba"
    When I run "cd tmp/aruba && zat translate create" command with the following details:
      | package name | test_package |
    Then the app file "tmp/aruba/translations/en.yml" is created with:
    """
    ---
    title: John Test App
    packages:
      - default
      - app_test_package
    parts:
      - translation:
        key: txt.apps.test_package.app.description
        title: ''
        value: Play the famous zen tunes in your help desk.
      - translation:
        key: txt.apps.test_package.app.name
        title: ''
        value: Buddha Machine
    """

