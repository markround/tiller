Feature: Tiller HTTP plugin

  Scenario: Load fixture
    Given I use a fixture named "http"
    Then  a file named "environments/development.yaml" should exist

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

  Scenario: Test environment without HTTP block
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["true"]
    data_sources: [ "http" , "file" ]
    template_sources: [ "http" , "file" ]

    environments:
      development:
        test.erb:
          target: test.txt
          config:
            test_var: "This is a template var from the development env"
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    test_var: <%= test_var %>
    """
    When I successfully run `tiller -b . -v -n -e development`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    test_var: This is a template var from the development env
    """
    And the output should contain "No HTTP configuration block for this environment"