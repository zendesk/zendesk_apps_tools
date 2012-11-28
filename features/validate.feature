Feature: validate a zendesk app

  Validate a zendesk app by running 'zat package' command

  Background: create a new zendesk app
    Given an app is created in directory "tmp/aruba"

  Scenario: valid app
    When I run `zat validate`
    Then the output should contain "validate  OK"
    And the exit status should be 0

  Scenario: invalid app (missing manifest.json
    Given I remove file "tmp/aruba/app/manifest.json"
    When I run `zat validate`
    Then the output should contain "Could not find manifest.json"
    And the exit status should not be 0