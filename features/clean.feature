Feature: clean tmp folder inside the zendesk app

  Background: create a new zendesk app package
    Given an app is created in directory "tmp/aruba"
    And I run `zat package`
    And the output should contain "package  created"

  Scenario: clean tmp folder
    When I run `zat clean`
    Then the zip file in "tmp/aruba/tmp" folder should not exist
    And the exit status should be 0