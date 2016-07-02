# Copyright (c) 2011-2016 Solano Labs All Rights Reserved
@mimic
Feature: spec command
  As a solano user
  In order to run tests
  I want to start a test session

Background:
  Given the command is "solano spec"

Scenario: Output messages in normal mode
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
  When I run `solano spec`
  Then the exit status should be 0
  And the output should contain "To view results"
  And the output should contain "Ctrl-C"
  And the output should contain "---> abcdef"
  And the output should not contain "---> abcdef --->"
