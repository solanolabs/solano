# Copyright (c) 2011-2016 Solano Labs All Rights Reserved
@mimic
Feature: spec command
  As a solano user
  In order to run tests
  I want to start a test session

  Background:
    Given the command is "solano spec"

Scenario: Auto-create a new suite with no .gitignore
  Given the destination repo exists
  And a git repo is initialized on branch "foobar"
  And the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
  And the user has no suites
  And the user can create a suite named "work/foobar" on branch "foobar"
  And the user creates a suite for "work/foobar" on branch "foobar"
  And the user can create a session
  And the user successfully registers tests for the suite
  And the tests start successfully
  And the test all pass
  When I run `solano spec`
  Then the exit status should be 0
  And the output should contain "Creating suite"
