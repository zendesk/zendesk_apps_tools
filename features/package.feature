Feature: package a zendesk app into a zip file

  Background: create a new zendesk app
    Given an app is created in directory "tmp/aruba/"

  Scenario: package a zendesk app by running 'zat package' command
    When I run `zat package`
    Then the output should contain "validate  OK"
    And the output should contain "package  adding app.js"
    And the output should contain "package  adding assets/logo-small.png"
    And the output should contain "package  adding assets/logo.png"
    And the output should contain "package  adding manifest.json"
    And the output should contain "package  adding templates/layout.hdbs"
    And the output should contain "package  adding translations/en.json"
    And the output should contain "package  created"
    And the zip file should exist in directory "tmp/aruba/tmp"
    And the exit status should be 0

