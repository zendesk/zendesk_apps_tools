Feature: list

  ZAT can list your apps

  Background:
    Given an app directory
    
  Scenario: package a directory
    When I run `zat list`
    Then the exit status should be 0
