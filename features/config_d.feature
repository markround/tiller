Feature: Configuration from config.d
  Background:
    Given a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    Test var : <%= test_var %>
    """
    And a file named "templates/additional.erb" with:
    """
    Additional var : <%= additional_var %>
    """
    And a directory named "config.d"

  Scenario: Override common.yaml
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["cat","test.txt"]
    data_sources: [ "file" ]
    template_sources: [ "file" ]
    environments:
      development:
        test.erb:
          target: test.txt
          config:
            test_var: 'From common.yaml'
    """
    And a file named "config.d/override.yaml" with:
    """
    ---
    data_sources: [ "file" , "environment" ]
    """
    When I successfully run `tiller -b . -n -v`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    Test var : From common.yaml
    """
    And the output should contain "Loading config file ./config.d/override.yaml"
    And the output should contain "Data sources loaded [FileDataSource, EnvironmentDataSource]"

  Scenario: Configuration from 3 separate files
    Given a file named "config.d/00-base.yaml" with:
    """
    ---
    exec: ["cat","test.txt"]
    data_sources: [ "defaults" , "file" ]
    template_sources: [ "file" ]
    """
    And a file named "config.d/01-defaults.yaml" with:
    """
    defaults:
      global:
        test_var: "From defaults module"
    """
    And a file named "config.d/02-environments.yaml" with:
    """
    environments:
      development:
        test.erb:
          target: test.txt
          config:
            test_var: 'From 02-environments.yaml'
    """
    When I successfully run `tiller -b . -n -v`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    Test var : From 02-environments.yaml
    """
    And the output should contain:
    """
    Loading config file ./config.d/00-base.yaml
    Loading config file ./config.d/01-defaults.yaml
    Loading config file ./config.d/02-environments.yaml
    """
    And the output should contain:
    """
    Warning, merging duplicate data values.
    test_var => 'From defaults module' being replaced by : 'From 02-environments.yaml' from FileDataSource
    """

  Scenario: Add additional templates in later configuration
    Given a file named "config.d/00-base.yaml" with:
    """
    ---
    exec: ["cat","test.txt"]
    data_sources: [ "file" ]
    template_sources: [ "file" ]
    """
    And a file named "config.d/01-development-base.yaml" with:
    """
    environments:
      development:
        test.erb:
          target: test.txt
          config:
            test_var: 'From 01-development-base.yaml'
    """
    And a file named "config.d/02-development-additional.yaml" with:
    """
    environments:
      development:
        additional.erb:
          target: additional.txt
          config:
            additional_var: 'From 02-development-additional.yaml'
    """
    When I successfully run `tiller -b . -n -v`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    Test var : From 01-development-base.yaml
    """
    And a file named "additional.txt" should exist
    And the file "additional.txt" should contain:
    """
    Additional var : From 02-development-additional.yaml
    """
    And the output should contain:
    """
    Loading config file ./config.d/00-base.yaml
    Loading config file ./config.d/01-development-base.yaml
    Loading config file ./config.d/02-development-additional.yaml
    """
