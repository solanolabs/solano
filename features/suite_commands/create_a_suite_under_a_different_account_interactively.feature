# Copyright (c) 2011 - 2016 Solano Labs All Rights Reserved

@mimic
Feature: suite command
  As a user
  In order to interact with Solano
  I want to configure a test suite

  Background:
    Given the command is "solano suite"

Scenario: Create a suite under a different account interactively
  Given the destination repo exists
  And a git repo is initialized on branch "test/foobar"
  And the user belongs to two accounts
  And the user is logged in
  And the user has no suites
  And the user can create a suite named "beta" on branch "test/foobar"
  When I run `solano suite` interactively
  When I respond to "organization" with "another_account"
  And I choose defaults for test pattern, CI settings
  Then "solano suite" output should contain "Using organization 'another_account'"
  Then "solano suite" output should contain "Created suite"
  When the console session ends
  Then the exit status should be 0
