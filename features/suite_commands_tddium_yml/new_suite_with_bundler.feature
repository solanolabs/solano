# Copyright (c) 2011-2016 Solano Labs All Rights Reserved

@mimic
Feature: suite command
  As a user
  In order to interact with Solano
  I want to configure a test suite

Background:
  Given the command is "solano suite"

Scenario Outline: Configure new suite with bundler from repo config file
  Given the user is logged in, and can successfully create a new suite in a git repo with bundler '1.3.5'
  And a file named "config/<file name>" with:
  """
  ---
  <root section>
    :bundler_version:  '1.3.5'
  """
  When I run `solano suite --name=beta --ci-pull-url=disable --ci-push-url=disable --test-pattern=spec/*`
  Then the output should contain "Looks like"
  Then the output should contain "Detected branch test/foobar"
  Then the output should contain "Configured bundler version 1.3.5 from config/<file name>"
  Then the output should contain "Created suite"
  Then the exit status should be 0
  Examples:
    | file name  | root section |
    | tddium.yml | :tddium:     |
    | tddium.cfg | :tddium:     |
    | solano.yml | :solano:     |
    | solano.yml |              |
