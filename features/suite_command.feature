# Copyright (c) 2011, 2012 Solano Labs All Rights Reserved

@mimic
Feature: suite command
  As a user
  In order to interact with Solano
  I want to configure a test suite

  Background:
    Given the command is "solano suite"

  Scenario: Fail if the user is not logged in
    Given the destination repo exists
    When I run `solano suite`
    Then it should fail with a login hint

  Scenario: Fail if CWD isn't in a git repo
    Given the user is logged in
    When I run `solano suite`
    Then the output should contain "not a suitable repository"
    And the exit status should not be 0

  Scenario: Configure a new suite with a complex branch
    Given the destination repo exists
    And a git repo is initialized on branch "test/foobar"
    And the user is logged in
    And the user has no suites
    And the user can create a suite named "beta" on branch "test/foobar"
    When I run `solano suite` interactively
    Then "solano suite" output should contain "Looks like"
    Then "solano suite" output should contain "Detected branch test/foobar"
    Then "solano suite" stderr should not contain "WARNING: Unable to parse"
    When I choose defaults for test pattern, CI settings
    Then "solano suite" output should contain "Using organization 'some_account'"
    Then "solano suite" output should contain "Created suite"
    When the console session ends
    Then the exit status should be 0

  Scenario: Edit a suite with CLI parameters
    Given the destination repo exists
    And a git repo is initialized on branch "test/foobar"
    And the user is logged in with a configured suite on branch "test/foobar"
    And the user can update the suite's test_pattern to "spec/foo"
    When I run `solano suite --edit --test-pattern=spec/foo --non-interactive` 
    Then the output should contain "Updated suite successfully"
    Then the exit status should be 0

  Scenario: Edit a suite's campfire room with CLI parameters
    Given the destination repo exists
    And a git repo is initialized on branch "test/foobar"
    And the user is logged in with a configured suite on branch "test/foobar"
    And the user can update the suite's campfire_room to "foobar"
    When I run `solano suite --edit --campfire-room=foobar --non-interactive` 
    Then the output should contain "Updated suite successfully"
    Then the exit status should be 0

  Scenario: Edit a suite's hipchat room with CLI parameters
    Given the destination repo exists
    And a git repo is initialized on branch "test/foobar"
    And the user is logged in with a configured suite on branch "test/foobar"
    And the user can update the suite's hipchat_room to "foobar"
    When I run `solano suite --edit --hipchat-room=foobar --non-interactive` 
    Then the output should contain "Updated suite successfully"
    Then the exit status should be 0

  Scenario: Configure a suite with a heroku push target
    Given the destination repo exists
    And a git repo is initialized on branch "test/foobar"
    And the user is logged in
    And the user has a .solano for branch "test/foobar"
    And the user has a heroku-push suite for "test" on "test/foobar"
    When I run `solano suite --name=test --non-interactive`
    Then the output should contain "Heroku"
    And the file ".solano-deploy-key.localhost" should contain "ssh-rsa"
    Then the exit status should be 0

  Scenario: Belong to mulitple accounts, fail if not provided
    Given the destination repo exists
    And a git repo is initialized on branch "test/foobar"
    And the user belongs to two accounts
    And the user is logged in
    And the user has no suites
    And the user can create a suite named "beta" on branch "test/foobar"
    When I run `solano suite` interactively
    Then "solano suite" output should contain "You are a member of these organizations:"
    Then "solano suite" output should contain "some_account"
    Then "solano suite" output should contain "another_account"
    When I respond to "account" with ""
    Then "solano suite" output should contain "You must specify an organization"
    When the console session ends
    Then the exit status should be 1

  Scenario: Create a suite under a different account interactively
    Given the destination repo exists
    And a git repo is initialized on branch "test/foobar"
    And the user belongs to two accounts
    And the user is logged in
    And the user has no suites
    And the user can create a suite named "beta" on branch "test/foobar"
    When I run `solano suite` interactively
    When I respond to "organization" with "another_account"
    And I choose defaults for test pattern, CI settings
    Then "solano suite" output should contain "Using organization 'another_account'"
    Then "solano suite" output should contain "Created suite"
    When the console session ends
    Then the exit status should be 0

  Scenario: Create a suite under a different account with an option
    Given the destination repo exists
    And a git repo is initialized on branch "test/foobar"
    And the user belongs to two accounts
    And the user is logged in
    And the user has no suites
    And the user can create a suite named "beta" on branch "test/foobar"
    When I run `solano suite --org=another_account --non-interactive`
    Then the output should contain "Using organization 'another_account'"
    And the output should contain "Created suite"
    And the exit status should be 0

  Scenario: Delete a suite when none exists
    Given a git repo is initialized on branch "test/foobar"
    And the user is logged in
    And the user has no suites
    When I run `solano suite --delete`
    Then the output should contain "Can't find suite"
    And the exit status should be 1

  Scenario: Delete a suite when one exists
    Given the command is "solano suite --delete"
    And a git repo is initialized on branch "test/foobar"
    And the user is logged in
    And the user has a suite for "test" on "foobar"
    And the suite deletion succeeds for 1
    When I run `solano suite --delete` interactively
    And I respond to "Are you sure" with "y"
    Then the exit status should be 0

  Scenario: Delete a suite by name
    Given the command is "solano suite --delete bar"
    And a git repo is initialized on branch "test/foo"
    And the user is logged in
    And the user has a suite for "test" on "bar"
    And the suite deletion succeeds for 1
    When I run `solano suite --delete bar` interactively
    And I respond to "Are you sure" with "y"
    Then the exit status should be 0

  Scenario: Delete a suite when more than one exists
    Given the command is "solano suite --delete"
    And a git repo is initialized on branch "test/foobar"
    And the user is logged in
    And the user has the following suites for the repo named "test":
      | id | branch | account |
      | 1  | foobar | org1    |
      | 2  | foobar | org2    |
    And the suite deletion succeeds for 2
    When I run `solano suite --delete` interactively
    And I respond to "Which organization" with "org2"
    And I respond to "Are you sure" with "y"
    Then the exit status should be 0
