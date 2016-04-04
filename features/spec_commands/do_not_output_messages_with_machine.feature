# Copyright (c) 2011-2016 Solano Labs All Rights Reserved
@mimic
Feature: spec command
  As a solano user
  In order to run tests
  I want to start a test session

  Background:
    Given the command is "solano spec"

Scenario: Don't output messages with --machine
  Given the destination repo exists
  And a git repo is initialized
  And the user is logged in with a configured suite
  And the user has the following keys:
    | name      |
    | default   |
  And the user can create a session
  And the user successfully registers tests for the suite
  And the tests start successfully
  And the test all pass with messages
  And the user can indicate repoman demand
  And the session completes
  When I run `solano spec --machine`
  Then the exit status should be 0
  And the output should not contain "Ctrl-C"
  And the output should not contain "--->"
