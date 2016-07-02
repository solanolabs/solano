# Copyright (c) 2013 Solano Labs All Rights Reserved

@mimic
Feature: Web command

Background:
  Given the command is "solano status"

Scenario: Run solano status
  When I run `solano status --argument=bogus`
  Then the exit status should be 1

Scenario: Run solano status with a session ID
  When I run `solano status --argument=bogus 1234`
  Then the exit status should be 1
