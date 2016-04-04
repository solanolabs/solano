# Copyright (c) 2011 - 2016 Solano Labs All Rights Reserved

@mimic
Feature: suite command
  As a user
  In order to interact with Solano
  I want to configure a test suite

  Background:
    Given the command is "solano suite"

Scenario: Delete a suite when none exists
  Given a git repo is initialized on branch "test/foobar"
  And the user is logged in
  And the user has no suites
  When I run `solano suite --delete`
  Then the output should contain "Can't find suite"
  And the exit status should be 1
