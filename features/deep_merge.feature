Feature: Test deep merging behaviour
  Background:
    Given a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    test_var: <%= test_var %>
    """


  Scenario: Test without deep merge
    Given a file named "common.yaml" with:
    """
    ---
    exec: true
    data_sources: [ "defaults" , "file" ]
    template_sources: [ "file" ]
    defaults:
      global:
        test_var:
          key1: 'key1 from defaults'
          key2: 'key2 from defaults'

    environments:
      development:
        test.erb:
          target: test.txt
          config:
            test_var:
              key1: 'key1 from file'
    """
    When I successfully run `tiller -b . -v -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    test_var: {"key1"=>"key1 from file"}
    """
  Scenario: Test with deep merge
    Given a file named "common.yaml" with:
    """
    ---
    exec: true
    data_sources: [ "defaults" , "file" ]
    template_sources: [ "file" ]
    deep_merge: true
    defaults:
      global:
        test_var:
          key1: 'key1 from defaults'
          key2: 'key2 from defaults'

    environments:
      development:
        test.erb:
          target: test.txt
          config:
            test_var:
              key1: 'key1 from file'
    """
    When I successfully run `tiller -b . -v -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    test_var: {"key1"=>"key1 from file", "key2"=>"key2 from defaults"}
    """

  Scenario: Test globals deep merge
    Given a file named "common.yaml" with:
    """
    ---
    exec: true
    data_sources: [ "defaults" , "file" ]
    template_sources: [ "file" ]
    deep_merge: true
    defaults:
      global:
        test_var:
          key1: 'key1 from defaults'
          key2: 'key2 from defaults'

    environments:
      development:
        global_values:
          test_var:
            key1: 'key1 from file'
        test.erb:
          target: test.txt

    """
    When I successfully run `tiller -b . -v -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    test_var: {"key1"=>"key1 from file", "key2"=>"key2 from defaults"}
    """