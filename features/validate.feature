Feature: validate a zendesk app

  Validate a zendesk app by running 'zat package' command

  Background: create a new zendesk app
    Given an app directory "tmp/aruba/" exists
    And I run "bundle exec bin/zat new" command with the following details:
      | author name  | John Citizen      |
      | author email | john@example.com  |
      | app name     | John Test App     |

  Scenario: valid app
    When I run `zat validate`
    Then the output should contain "validate  OK"
    And the exit status should be 0

  Scenario: invalid app (missing manifest.json
    Given I remove file "tmp/aruba/app/manifest.json"
    When I run `zat validate`
    Then the output should contain "Could not find manifest.json"
    And the exit status should not be 0