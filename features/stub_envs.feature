Feature: Stub environments

  Background:
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["true"]
    data_sources: [ "defaults" , "file" ]
    template_sources: [ "file" ]

    defaults:
      test.erb:
        target: test.txt
        config:
          test_var: "This is a template var from defaults"

    environments:
      stub:
      development:
        test.erb:
          config:
            test_var: "This is a template var from the development env"
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    test_var: <%= test_var %>
    """

  Scenario: Test development environment
    When I successfully run `tiller -b . -v -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "test_var: This is a template var from the development env"

  Scenario: Test stub environment
    When I successfully run `tiller -b . -v -n -e stub`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "test_var: This is a template var from defaults"

  Scenario: Test no environment
    When I run `tiller -b . -v -n -e non_existant`
    Then the output should contain "Error : Could not load environment non_existant from common.yaml"
