# Copyright (c) 2011, 2012 Solano Labs All Rights Reserved

@mimic
Feature: Logout Command

  Scenario: Logout successfully
    Given a file named ".solano.localhost" with:
    """
    {'api_key':'abcdef'}
    """
    And a solano global config file exists
    When I run `solano logout --host=localhost` interactively
    And the console session ends
    Then the output should contain:
    """
    Logged out successfully
    """
    And the exit status should be 0
    And the file ".solano.localhost" should not exist
    And the solano global config file should not exist
