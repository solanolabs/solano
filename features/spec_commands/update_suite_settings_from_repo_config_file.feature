# Copyright (c) 2011-2016 Solano Labs All Rights Reserved
@mimic
Feature: spec command
  As a solano user
  In order to run tests
  I want to start a test session

Background:
  Given the command is "solano spec"

Scenario Outline: Update suite settings from repo config file
  Given the destination repo exists
  And a git repo is initialized
  And the user is logged in with a configured suite
  And the user has the following keys:
    | name      |
    | default   |
  And a file named "config/<file name>" with:
  """
  ---
  <root section>
    :test_pattern:
      - spec/foo_spec.rb
      - features/blah.feature
  """
  And the user can update the suite's test_pattern to "spec/foo_spec.rb,features/blah.feature"
  And the user can create a session
  And the user successfully registers tests for the suite
  And the tests start successfully
  And the test all pass with messages
  When I run `solano spec`
  Then the exit status should be 0
  And the output should contain "Updated test pattern"
  Examples:
    | file name  | root section |
    | tddium.yml | :tddium:     |
    | tddium.cfg | :tddium:     |
    | solano.yml | :solano:     |
    | solano.yml |              |
