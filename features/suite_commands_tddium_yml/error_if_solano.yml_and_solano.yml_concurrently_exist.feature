# Copyright (c) 2011-2016 Solano Labs All Rights Reserved

@mimic
Feature: suite command
  As a user
  In order to interact with Solano
  I want to configure a test suite

  Background:
    Given the command is "solano suite"

Scenario: Exit with error if solano.yml and solano.yml concurrently exist
  Given the user is logged in, and can successfully create a new suite in a git repo
  And a file named "config/tddium.yml" with:
  """
  ---
  :tddium:
    :ruby_version:  ruby-1.9.2-p290-psych
  """
  And a file named "config/solano.yml" with:
  """
  ---
  :ruby_version:  ruby-1.9.2-p290-psych
  """
  When I run `solano suite` interactively
  Then "solano suite" output should contain "You have both solano.yml and tddium.yml in your repo"
  When the console session ends
  Then the exit status should not be 0
