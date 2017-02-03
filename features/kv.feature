Feature: Dynamic configuration

Background:
    Given a directory named "lib/tiller/helper"
    And a file named "lib/tiller/helper/test.rb" with:
    """
    module Tiller::TestHelper
      def self.test
        Tiller::Kv.get('/test/string', namespace: 'test')
      end
    end
    """
    Given a directory named "lib/tiller/data"
    And a file named "lib/tiller/data/test.rb" with:
    """
    class TestDataSource < Tiller::DataSource
      def setup
        Tiller::Kv.set('/test/string', 'Test string from KV store', namespace: 'test')
      end
    end
    """

Scenario: Test dynamic configuration
Given a file named "common.yaml" with:
    """
    ---
    exec: [ "cat" , "test.txt" ]
    data_sources: [ "file", "test" ]
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
    Value from KV : <%= Tiller::TestHelper.test %>
    """
When I successfully run `tiller -vd -b . -l ./lib`
Then a file named "test.txt" should exist
And the file "test.txt" should contain "Value from KV : Test string from KV store"
And the output should contain "KV: Setting [test]/test/string = Test string from KV store"
