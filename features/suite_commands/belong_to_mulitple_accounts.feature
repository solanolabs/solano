# Copyright (c) 2011 - 2016 Solano Labs All Rights Reserved

@mimic
Feature: suite command
  As a user
  In order to interact with Solano
  I want to configure a test suite

Background:
  Given the command is "solano suite"

Scenario: Belong to mulitple accounts, fail if not provided
  Given the destination repo exists
  And a git repo is initialized on branch "test/foobar"
  And the user belongs to two accounts
  And the user is logged in
  And the user has no suites
  And the user can create a suite named "beta" on branch "test/foobar"
  When I run `solano suite` interactively
  Then "solano suite" output should contain "You are a member of these organizations:"
  Then "solano suite" output should contain "some_account"
  Then "solano suite" output should contain "another_account"
  When I respond to "account" with ""
  Then "solano suite" output should contain "You must specify an organization"
  When the console session ends
  Then the exit status should be 1
