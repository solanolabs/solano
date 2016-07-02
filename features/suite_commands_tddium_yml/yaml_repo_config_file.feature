# Copyright (c) 2011-2016 Solano Labs All Rights Reserved

@mimic
Feature: suite command
  As a user
  In order to interact with Solano
  I want to configure a test suite

Background:
  Given the command is "solano suite"

Scenario Outline: Non-YAML repo config file should generate a warning and then prompt
  Given the user is logged in, and can successfully create a new suite in a git repo
  And a file named "config/<file name>" with:
  """
  ---
  <root section>
    :test_pattern:
      - spec/controllers/**_spec.rb
      +
  """
  When I run `solano suite` interactively
  Then "solano suite" output should contain "Unable to parse"
  Then "solano suite" output should contain "Looks like"
  Then "solano suite" output should not contain "Configured ruby ruby-1.9.2-p290-psych from config/<file name>"
  Then "solano suite" output should contain "Detected ruby"
  When I choose defaults for test pattern, CI settings
  Then "solano suite" output should contain "Created suite"
  When the console session ends
  Then the exit status should be 0
  Examples:
    | file name  | root section |
    | tddium.yml | :tddium:     |
    | tddium.cfg | :tddium:     |
    | solano.yml | :solano:     |
    | solano.yml |              |
