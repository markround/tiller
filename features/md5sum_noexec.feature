Feature: MD5 file checksums with noexec
  Background:
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["true"]
    data_sources: [ "file" ]
    template_sources: [ "file" ]
    md5sum: true
    md5sum_noexec: true
    environments:
      development:
        test1.erb:
          target: test1.txt
          config:
            test_var: "This is a variable from the file datasource"
        test2.erb:
          target: test2.txt
          config:
            test_var: "This is a variable from the file datasource"
    """
    And a directory named "templates"
    And a file named "templates/test1.erb" with:
    """
    test_var: <%= test_var %>
    """
    And a file named "templates/test2.erb" with:
    """
    test_var: <%= test_var %>
    """

  Scenario: First pass
    When I successfully run `tiller -b . -v -e development`
    Then a file named "test1.txt" should exist
    And the file "test1.txt" should contain:
    """
    test_var: This is a variable from the file datasource
    """
    Then a file named "test2.txt" should exist
    And the file "test2.txt" should contain:
    """
    test_var: This is a variable from the file datasource
    """
    And the output should contain:
    """
    [2/2] templates written, [0] skipped with no change
    Template generation completed
    Executing ["true"]...
    """

  Scenario: Test with only one change needed
    Given a file named "test1.txt" with:
    """
    test_var: This is a variable from the file datasource
    """
    When I successfully run `tiller -b . -d -e development`
    Then the output should contain:
    """
    [1/2] templates written, [1] skipped with no change
    Template generation completed
    Executing ["true"]...
    """

  Scenario: Test with no changes needed
    Given a file named "test1.txt" with:
    """
    test_var: This is a variable from the file datasource
    """
    And a file named "test2.txt" with:
    """
    test_var: This is a variable from the file datasource
    """
    When I successfully run `tiller -b . -d -e development`
    Then the output should contain:
    """
    [0/2] templates written, [2] skipped with no change
    Template generation completed
    No templates written, stopping without exec
    """

