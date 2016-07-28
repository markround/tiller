Feature: Helper modules
  Background:
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["true"]
    data_sources: [ "file" ]
    template_sources: [ "file" ]
    helpers: [ "test" ]
    environments:
      development:
        test.erb:
          target: test.txt
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    test module : <%= Tiller::Test.echo('Hello, world!') -%>
    """
    And a directory named "lib/tiller/helper"
    And a file named "lib/tiller/helper/test.rb" with:
    """
    module Tiller::Test
      def self.echo(text)
        "#{text}"
      end
    end
    """

  Scenario: Generate template with module
    When I successfully run `tiller -b . -l ./lib -v`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    test module : Hello, world!
    """
    And the output should contain:
    """
    Helper modules loaded ["test"]
    """