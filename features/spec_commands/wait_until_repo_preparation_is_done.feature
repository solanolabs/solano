# Copyright (c) 2011-2016 Solano Labs All Rights Reserved
@mimic
Feature: spec command
  As a solano user
  In order to run tests
  I want to start a test session

  Background:
    Given the command is "solano spec"

Scenario: Wait until repo preparation is done
  Given the destination repo exists
  And the SCM ready timeout is 0
  And a git repo is initialized on branch "foobar"
  And the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
  And the user has no suites
  And the user can create a suite named "work/foobar" on branch "foobar"
  And the user creates a pending suite for "work/foobar" on branch "foobar"
  And the user can create a session
  And the user successfully registers tests for the suite
  And the tests start successfully
  And the test all pass
  And the user can indicate repoman demand
  When I run `solano spec`
  Then the exit status should be 1
  And the output should contain "Creating suite"
  And the output should contain "prepped"
