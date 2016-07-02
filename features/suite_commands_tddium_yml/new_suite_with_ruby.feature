# Copyright (c) 2011-2016 Solano Labs All Rights Reserved

@mimic
Feature: suite command
  As a user
  In order to interact with Solano
  I want to configure a test suite

Background:
  Given the command is "solano suite"

Scenario Outline: Configure new suite with ruby from repo config file
  Given the user is logged in, and can successfully create a new suite in a git repo
  And a file named "config/<file name>" with:
  """
  ---
  <root section>
     :ruby_version:  ruby-1.9.2-p290-psych
  """
  When I run `solano suite --name=beta --ci-pull-url=disable --ci-push-url=disable --test-pattern=spec/*`
  Then the output should contain "Looks like"
  Then the output should contain "Detected branch test/foobar"
  Then the output should contain "Configured ruby ruby-1.9.2-p290-psych from config/<file name>"
  Then the output should contain "Created suite"
  Then the exit status should be 0
  Examples:
    | file name  | root section |
    | tddium.yml | :tddium:     |
    | tddium.cfg | :tddium:     |
    | solano.yml | :solano:     |
    | solano.yml |              |
