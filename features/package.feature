Feature: package a zendesk app into a zip file

  Background: create a new zendesk app


  Scenario: package a zendesk app by running 'zat package' command
    Given an app is created in directory "tmp/aruba"
    When I run the command "zat package --path tmp/aruba" to package the app
    And the command output should contain "adding assets/iframe.html"
    And the command output should contain "adding assets/logo-small.png"
    And the command output should contain "adding assets/logo.png"
    And the command output should contain "adding manifest.json"
    And the command output should contain "adding translations/en.json"
    And the command output should contain "created"
    And the zip file should exist in directory "tmp/aruba/tmp"

  Scenario: package a zendesk app by running 'zat package' command
    Given an app is created in directory "tmp/aruba"
    When I create a symlink from "./templates/translation.erb.tt" to "tmp/aruba/assets/translation.erb.tt"
    Then "tmp/aruba/assets/translation.erb.tt" should be a symlink
    When I run the command "zat package --path tmp/aruba" to package the app
    Then the zip file in "tmp/aruba/tmp" should not contain any symlinks
