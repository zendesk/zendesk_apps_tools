Feature: validate a zendesk app

  Validate a zendesk app by running 'zat package' command

  Background: create a new zendesk app
    Given an app is created in directory "tmp/aruba"

  Scenario: valid app
    When I run the command "zat validate --path tmp/aruba" to validate the app
    Then it should pass the validation

  Scenario: invalid app (missing manifest.json
    Given I remove file "tmp/aruba/manifest.json"
    When I run the command "zat validate --path tmp/aruba" to validate the app
    Then the command output should contain "Could not find manifest.json"
