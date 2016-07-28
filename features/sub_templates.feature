Feature: Sub templates
  Background:
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["true"]
    data_sources: [ "file" ]
    template_sources: [ "file" ]
    environments:
      development:
        test.erb:
          target: test.txt
          config:
            test_var: "This is a variable from the file datasource"
            sub1_var: "Value for the sub-template"
            sub2_var: "Value for the sub-sub-template"

    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    test_var: <%= test_var %>
    <%= Tiller::render('sub1.erb') -%>
    """
    And a file named "templates/sub1.erb" with:
    """
    sub1_var: <%= sub1_var %>
    <%= Tiller::render('sub2.erb') -%>
    """
    And a file named "templates/sub2.erb" with:
    """
    sub2_var: <%= sub2_var -%>
    """

  Scenario: Generate sub-template
    When I successfully run `tiller -b . -v -e development`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    test_var: This is a variable from the file datasource
    sub1_var: Value for the sub-template
    sub2_var: Value for the sub-sub-template
    """
