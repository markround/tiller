Feature: Tiller environment plugin

  Scenario: Load fixture
    Given I use a fixture named "environment_plugin"
    Then  a file named "environments/development.yaml" should exist

  Scenario: Simple data from environment
    Given I use a fixture named "environment_plugin"
    Given I set the environment variables exactly to:
      | variable    | value           |
      | test        | Hello, World!   |
    When I successfully run `tiller -b . -v -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "Hello, World!"

  Scenario: Local config overrides global plugin
    Given I use a fixture named "environment_plugin"
    Given I set the environment variables exactly to:
      | variable    | value           |
      | test        | Hello, World!   |
    When I successfully run `tiller -b . -v -n -e local_override`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "This value overwrites the global value provided by the environment plugin"

  Scenario: Custom prefix
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["true"]
    data_sources: [ "file" , "environment" ]
    template_sources: [ "file" ]
    environment:
      prefix: 'foo_'
    environments:
      development:
        test1.erb:
          target: test1.txt
    """
    And a directory named "templates"
    And a file named "templates/test1.erb" with:
    """
    foo_var: <%= foo_var %>
    """
    And I set the environment variables exactly to:
      | variable    | value           |
      | VAR         | Hello, World!   |
    When I successfully run `tiller -b . -v -n`
    Then a file named "test1.txt" should exist
    And the file "test1.txt" should contain "foo_var: Hello, World!"

  Scenario: Custom prefix, no lowercase
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["true"]
    data_sources: [ "file" , "environment" ]
    template_sources: [ "file" ]
    environment:
      prefix: 'foo_'
      lowercase: false
    environments:
      development:
        test1.erb:
          target: test1.txt
    """
    And a directory named "templates"
    And a file named "templates/test1.erb" with:
    """
    foo_var: <%= foo_VAR %>
    """
    And I set the environment variables exactly to:
      | variable    | value           |
      | VAR         | Hello, World!   |
    When I successfully run `tiller -b . -v -n`
    Then a file named "test1.txt" should exist
    And the file "test1.txt" should contain "foo_var: Hello, World!"

  Scenario: Null prefix
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["true"]
    data_sources: [ "file" , "environment" ]
    template_sources: [ "file" ]
    environment:
      prefix: ''
    environments:
      development:
        test1.erb:
          target: test1.txt
    """
    And a directory named "templates"
    And a file named "templates/test1.erb" with:
    """
    var: <%= var %>
    """
    And I set the environment variables exactly to:
      | variable    | value           |
      | VAR         | Hello, World!   |
    When I successfully run `tiller -b . -v -n`
    Then a file named "test1.txt" should exist
    And the file "test1.txt" should contain "var: Hello, World!"