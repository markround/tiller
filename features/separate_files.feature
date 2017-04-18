Feature: File plugin
  Scenario: Load fixture
    Given I use a fixture named "separate_files" 
    Then  a file named "environments/empty_env.yaml" should exist

  Scenario: Separate environment file that is empty
    Given I use a fixture named "separate_files" 
    When I successfully run `tiller -b . -e empty_env -n`
    Then a file named "file.conf" should exist
    And the file "file.conf" should contain:
"""
thing=default_value
"""

  Scenario: Separate environment file that is not empty
    Given I use a fixture named "separate_files" 
    When I successfully run `tiller -b . -e not_empty_env -n`
    Then a file named "file.conf" should exist
    And the file "file.conf" should contain:
"""
thing=not_default
"""
