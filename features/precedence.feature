Feature: Test new value precedence and merging behaviour
  Background:
    Given a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    test_var: <%= test_var %>
    """


  Scenario: Global vars from two plugins
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ 'cat','test.txt' ]
    data_sources: [ "defaults" , "file"  ]
    template_sources: [ "file" ]
    defaults:
      test_var: "From defaults plugin"

    environments:
      development:
        global_values:
          test_var: 'From file plugin'
        test.erb:
          target: test.txt

    """
    When I successfully run `tiller -b . -v`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    test_var: From file plugin
    """

  Scenario: Template vars from two plugins
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ 'cat','test.txt' ]
    data_sources: [ "defaults" , "file" ]
    template_sources: [ "file" ]
    defaults:
      test.erb:
        test_var: "From defaults plugin"

    environments:
      development:
        test.erb:
          target: test.txt
          config:
            test_var: "From file plugin"
    """
    When I successfully run `tiller -b . -v`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    test_var: From file plugin
    """

  Scenario: Environment global should over-ride template vars from earlier plugins
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ 'cat','test.txt' ]
    data_sources: [ "defaults" , "file" , "environment" ]
    template_sources: [ "file" ]
    environment:
      prefix: 'test_'
    defaults:
      test.erb:
        test_var: "From defaults plugin"

    environments:
      development:
        test.erb:
          target: test.txt
          config:
            test_var: "From file plugin"
    """
    And I set the environment variables exactly to:
      | variable    | value              |
      | var         | from environment   |
    When I successfully run `tiller -b . -v`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    test_var: from environment
    """
    And the output should contain:
    """
    Merging duplicate data values
    test_var => 'From defaults plugin' being replaced by : 'From file plugin' from FileDataSource
    test_var => 'From file plugin' being replaced by : 'from environment' from EnvironmentDataSource
    """

