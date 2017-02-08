Feature: Exec on write

  Scenario: Test exec_on_write enforces Array syntax
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "cat" , "test.txt" ]
    data_sources: [ "file" ]
    template_sources: [ "file" ]

    environments:
      development:
        test.erb:
          target: test.txt
          exec_on_write: touch exec_on_write.tmp
          config:
            value: exec_on_write feature
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    value: <%= value %>
    """
    When I run `tiller -vd -b . -l ./lib`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "value: exec_on_write feature"
    And the output should match /Warning: exec_on_write for template (.+) is not in array format/

  Scenario: Test exec_on_write
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "cat" , "test.txt" ]
    data_sources: [ "file" ]
    template_sources: [ "file" ]

    environments:
      development:
        test.erb:
          target: test.txt
          exec_on_write: ["touch" , "exec_on_write.tmp"]
          config:
            value: exec_on_write feature
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    value: <%= value %>
    """
    When I successfully run `tiller -vd -b . -l ./lib`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "value: exec_on_write feature"
    And a file named "exec_on_write.tmp" should exist
    And the output should match /exec_on_write process for (.+) forked with PID ([0-9]+)/
    And the output should match /exec_on_write process with PID ([0-9]+) exited with status 0/
    And the output should match /Main child process with PID ([0-9]+) exited with status 0/

  Scenario: Test exec_on_write does not exec when md5 checksums match
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "cat" , "test.txt" ]
    data_sources: [ "file" ]
    template_sources: [ "file" ]
    md5sum: true

    environments:
      development:
        test.erb:
          target: test.txt
          exec_on_write: ["touch" , "exec_on_write.tmp"]
          config:
            value: exec_on_write feature
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    value: <%= value %>
    """
    Given a file named "test.txt" with:
    """
    value: exec_on_write feature
    """
    When I successfully run `tiller -vd -b . -l ./lib`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "value: exec_on_write feature"
    And the output should contain "[0/1] templates written, [1] skipped with no change"
    And a file named "exec_on_write.tmp" should not exist
    And the output should not match /exec_on_write process for (.+) forked with PID ([0-9]+)/
