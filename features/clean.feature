Feature: clean tmp folder inside the zendesk app

  Background: create a new zendesk app package
    Given an app directory "tmp/aruba/" exists
    And I run "bundle exec bin/zat new" command with the following details:
      | author name  | John Citizen      |
      | author email | john@example.com  |
      | app name     | John Test App     |
    And I run `zat package`
    And the output should contain "package  created"

  Scenario: clean tmp folder
    When I run `zat clean`
    Then the zip file in "tmp/aruba/tmp" folder should not exist
    And the exit status should be 0