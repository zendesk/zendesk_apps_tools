Feature: clean tmp folder inside the zendesk app

  Background: create a new zendesk app package
    Given an app is created in directory "tmp/aruba"
    And I run the command "zat package --path tmp/aruba" to package the app

  Scenario: clean tmp folder
    When I run the command "zat clean --path tmp/aruba" to clean the app
    Then the zip file in "tmp/aruba/tmp" folder should not exist
