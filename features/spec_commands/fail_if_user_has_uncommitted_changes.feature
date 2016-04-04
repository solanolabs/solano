# Copyright (c) 2011-2016 Solano Labs All Rights Reserved
@mimic
Feature: spec command
  As a solano user
  In order to run tests
  I want to start a test session

  Background:
    Given the command is "solano spec"

@announce-cmd
Scenario: Fail if user has uncommitted changes
  Given a git repo is initialized
  And the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
  And the user has a suite for "repo" on "master"
  And the user can create a session
  But the user has uncommitted changes to "foo.rb"
  When I run `solano spec`
  Then the exit status should not be 0
  And the output should contain "uncommitted"
