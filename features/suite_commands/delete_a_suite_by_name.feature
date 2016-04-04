# Copyright (c) 2011 - 2016 Solano Labs All Rights Reserved

@mimic
Feature: suite command
  As a user
  In order to interact with Solano
  I want to configure a test suite

  Background:
    Given the command is "solano suite"

Scenario: Delete a suite by name
  Given the command is "solano suite --delete bar"
  And a git repo is initialized on branch "test/foo"
  And the user is logged in
  And the user has a suite for "test" on "bar"
  And the suite deletion succeeds for 1
  When I run `solano suite --delete bar` interactively
  And I respond to "Are you sure" with "y"
  Then the exit status should be 0
