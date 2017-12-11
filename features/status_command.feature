@mimic
Feature: "solano status" command
  As a Solano user
  In order to view my recent sessions
  I want a simple status display

Background:
  Given the command is "solano status"

Scenario: Fail if user isn't logged in
  Given a git repo is initialized
  When I run `solano status`
  Then the exit status should not be 0
  And the output should contain "solano login"

Scenario: Get status for unique suite
  Given the command is "solano status"
  And a git repo is initialized on branch "foobar"
  And the user is logged in
  And the user has the following suites for the repo named "test":
    | id | branch | account |
    | 1  | foobar | org1    |
  When I successfully run `solano status`
  Then "solano status" output should contain "There are no "
  Then the exit status should be 0

Scenario: Get status for same repo and branch shared between different organizations
  Given the command is "solano status"
  And a git repo is initialized on branch "foobar"
  And the user is logged in
  And the user has the following suites for the repo named "test":
    | id | branch | account |
    | 1  | foobar | org1    |
    | 2  | foobar | org2    |
  When I run `solano status` interactively
  And I respond to "Which organization" with "org2"
  Then "solano status" output should contain "There are no "
  Then the exit status should be 0

Scenario: Get status with --org option for same repo and branch shared between different organizations
  Given the command is "solano status"
  And a git repo is initialized on branch "foobar"
  And the user is logged in
  And the user has the following suites for the repo named "test":
    | id | branch | account |
    | 1  | foobar | org1    |
    | 2  | foobar | org2    |
  When I successfully run `solano status --org org2`
  Then "solano status --org org2" output should contain "There are no "
  Then the exit status should be 0
