Feature: package a zendesk app into a zip file

  Background: create a new zendesk app
    Given an app is created in directory "tmp/aruba"

  Scenario: package a zendesk app by running 'zat package' command
    When I run the command "zat package --path tmp/aruba" to package the app
    And the command output should contain "adding app.js"
    And the command output should contain "adding assets/logo-small.png"
    And the command output should contain "adding assets/logo.png"
    And the command output should contain "adding manifest.json"
    And the command output should contain "adding templates/layout.hdbs"
    And the command output should contain "adding translations/en.json"
    And the command output should contain "created"
    And the zip file should exist in directory "tmp/aruba/tmp"
