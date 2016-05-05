Feature: File global values module
  Scenario: Load fixture
    Given I use a fixture named "file_globals"
    Then  a file named "v1/environments/production.yaml" should exist

  Scenario: Globals from v1 development environment
    Given I use a fixture named "file_globals"
    When I successfully run `tiller -b ./v1 -v -e development -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
"""
Global value : This is available to all environments
Local value : This is the development environment
Per-environment global : This is a per-env global for the development environment
"""
    And a file named "test2.txt" should exist
    And the file "test2.txt" should contain:
"""
Global value : This is available to all environments
Local value : This is the development environment
Per-environment global : This is the per-env global overwritten by the local value
"""

  Scenario: Globals from v1 production environment
    Given I use a fixture named "file_globals"
    When I successfully run `tiller -b ./v1 -v -e production -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
"""
Global value : This is available to all environments
Local value : This is the production environment
Per-environment global : This is the default for the per-env global
"""



  Scenario: Globals from v2 development environment
    Given I use a fixture named "file_globals"
    When I successfully run `tiller -b ./v2 -v -e development -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
"""
Global value : This is available to all environments
Local value : This is the development environment
Per-environment global : This is a per-env global for the development environment
"""
    And a file named "test2.txt" should exist
    And the file "test2.txt" should contain:
"""
Global value : This is available to all environments
Local value : This is the development environment
Per-environment global : This is the per-env global overwritten by the local value
"""

  Scenario: Globals from v2 production environment
    Given I use a fixture named "file_globals"
    When I successfully run `tiller -b ./v2 -v -e production -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
"""
Global value : This is available to all environments
Local value : This is the production environment
Per-environment global : This is the default for the per-env global
"""
