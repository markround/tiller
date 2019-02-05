Feature: Test only specified templates are generated
  Scenario: Specify templates
    Given a file named "common.yaml" with:
    """
    ---
    data_sources: [ "file" ]
    template_sources: [ "file" ]

    environments:
      development:
        test1.erb:
          target: test1.txt
          config:
            value: First template
        test2.erb:
          target: test2.txt
          config:
            value: Second template
        test3.erb:
          target: test3.txt
          config:
            value: Third template
    """
    And a directory named "templates"
    And a file named "templates/test1.erb" with:
    """
    value: <%= value %>
    """
    And a file named "templates/test2.erb" with:
    """
    value: <%= value %>
    """
    And a file named "templates/test3.erb" with:
    """
    value: <%= value %>
    """
    When I run `tiller -n -vd -b . -l ./lib --templates test1.erb,test3.erb`
    Then a file named "test1.txt" should exist
    And the file "test1.txt" should contain "value: First template"
    And a file named "test2.txt" should not exist
    Then a file named "test3.txt" should exist
    And the file "test3.txt" should contain "value: Third template"
    And the output should match /Template test2.erb is not in the list of templates to generate, skipping.../
