Feature: Configure tiller with environment variables

  Scenario: Set tiller_lib
    Given I set the environment variables exactly to:
      | variable          | value       |
      | tiller_lib        | /tmp        |
    When I run `tiller -h`
    Then the output should contain:
"""
:tiller_lib=>"/tmp"
"""

  Scenario: Set environment
    Given I set the environment variables exactly to:
      | variable          | value       |
      | environment       | test        |
    When I run `tiller -h`
    Then the output should contain:
    """
:environment=>"test"
"""

