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
