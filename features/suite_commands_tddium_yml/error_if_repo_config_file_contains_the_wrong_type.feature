# Copyright (c) 2011-2016 Solano Labs All Rights Reserved

@mimic
Feature: suite command
  As a user
  In order to interact with Solano
  I want to configure a test suite

  Background:
    Given the command is "solano suite"

Scenario Outline: Exit with error if repo config file contains the wrong type
  Given the user is logged in, and can successfully create a new suite in a git repo
  And a file named "config/<file name>" with:
  """
  ---
  <root section>
    :test_pattern:
      :this: is
      :not: a list
  """
  When I run `solano suite` interactively
  Then "solano suite" output should contain "Looks like"
  And "solano suite" output should contain "not properly formatted"
  When the console session ends
  Then the exit status should not be 0
  Examples:
    | file name  | root section |
    | tddium.yml | :tddium:     |
    | tddium.cfg | :tddium:     |
    | solano.yml | :solano:     |
    | solano.yml |              |
