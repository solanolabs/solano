# Copyright (c) 2011-2016 Solano Labs All Rights Reserved
@mimic
Feature: spec command
  As a solano user
  In order to run tests
  I want to start a test session

Background:
  Given the command is "solano spec"

Scenario: Use suite on API server but not in local configuration
  Given the destination repo exists
  And a git repo is initialized
  And the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
  And the user has a suite for "repo" on "master"
  And the user can create a session
  And the user successfully registers tests for the suite
  And the session starts successfully
  And the test all pass
  When I run `solano spec`
  Then the exit status should be 0
