Feature: Tiller HTTP plugin

  Scenario: Load fixture
    Given I use a fixture named "http"
    Then  a file named "environments/development.yaml" should exist

  @debug
  Scenario: Data and templates from HTTP test server
    Given I use a fixture named "http"
    When I successfully run `tiller -b . -v -n`
    Then a file named "http.txt" should exist
    And the file "http.txt" should contain:
"""
The HTTP Value is : This came from the development environment.
Some globals, now.

 * This is a value from HTTP 
 * Another global value 
"""