# Copyright (c) 2011-2016 Solano Labs All Rights Reserved
@mimic
Feature: spec command
  As a solano user
  In order to run tests
  I want to start a test session

Background:
  Given the command is "solano spec"

Scenario: Fail if user isn't logged in
  Given a git repo is initialized
  When I run `solano spec`
  Then the exit status should not be 0
  And the output should contain "solano login"
