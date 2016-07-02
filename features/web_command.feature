# Copyright (c) 2011, 2012 Solano Labs All Rights Reserved

@mimic
Feature: Web command

Background:
  Given the command is "solano web"

Scenario: Run solano web
  Given a git repo is initialized
  When I run `solano web`
  Then the exit status should be 0

Scenario: Run solano web with a session ID
  When I run `solano web 1234`
  Then the exit status should be 0
