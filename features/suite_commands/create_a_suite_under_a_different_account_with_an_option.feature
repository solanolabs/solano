# Copyright (c) 2011 - 2016 Solano Labs All Rights Reserved

@mimic
Feature: suite command
  As a user
  In order to interact with Solano
  I want to configure a test suite

  Background:
    Given the command is "solano suite"

Scenario: Create a suite under a different account with an option
  Given the destination repo exists
  And a git repo is initialized on branch "test/foobar"
  And the user belongs to two accounts
  And the user is logged in
  And the user has no suites
  And the user can create a suite named "beta" on branch "test/foobar"
  When I run `solano suite --org=another_account --non-interactive`
  Then the output should contain "Using organization 'another_account'"
  And the output should contain "Created suite"
  And the exit status should be 0
