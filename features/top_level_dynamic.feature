@ruby21
Feature: Top level dynamic values
  Background:
    Given a directory named "lib/tiller/data"
    And a file named "lib/tiller/data/dynamic_values_test.rb" with:
    """
    require 'tiller/datasource'

    class DynamicValuesTest < Tiller::DataSource
      def setup
        if Tiller::config.has_key?('dynamic_values_test')
          Tiller::log.debug("Value of key from config is : #{Tiller::config['dynamic_values_test']['dynamic_value_for_plugin']}")
        else
          Tiller::log.warn('No dynamic_values_test config block')
        end
      end
    end
    """

  Scenario: Generate template with module
    Given a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    Env var : <%= env_test_value -%>
    """
    And a file named "common.yaml" with:
    """
    ---
    data_sources: [ 'environment' , 'file' , 'dynamic_values_test' ]
    template_sources: [ 'file' ]
    dynamic_values: true

    dynamic_values_test:
      dynamic_value_for_plugin: "<%= env_test_value %>"

    environments:
      development:
        common:
          dynamic_global_var: "global var : <%= env_test_value %>"
        test.erb:
          target: "<%= env_test_value %>"
    """
    And I set the environment variables exactly to:
      | variable          | value       |
      | test_value        | test.txt    |
    When I successfully run `tiller -b . -l ./lib -dnv`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    Env var : test.txt
    """
    And the output should contain "Parsing top-level values for ERb syntax"
    And the output should contain "Parsed ERb of environments/development/common/dynamic_global_var as global var : test.txt"
    And the output should contain "Parsed ERb of dynamic_values_test/dynamic_value_for_plugin as test.txt"
    And the output should contain "Value of key from config is : test.txt"

  Scenario: Test passing in hostname as a value to HTTP plugin
    Given a file named "common.yaml" with:
    """
    data_sources: [ 'file' , 'environment' , 'http' ]
    template_sources: [ 'http' , 'file' ]
    dynamic_values: true
    environments:
      development:
        common:
          http:
            uri: 'http://<%= env_http_host -%>/http_test'
            timeout: 10
            templates: '/environments/%e/templates'
            template_content: '/templates/%t/content'

            values:
              global: '/globals'
              template: '/templates/%t/values/%e'
              target: '/templates/%t/target_values/%e'
    """
    And I set the environment variables exactly to:
      | variable          | value               |
      | http_host         | markround.github.io |
    When I successfully run `tiller -b . -dnv`
    Then a file named "http.txt" should exist
    And the file "http.txt" should contain:
    """
    The HTTP Value is : This came from the development environment.
    Some globals, now.

     * This is a value from HTTP
    """
    And the output should contain "Parsed ERb of environments/development/common/http/uri as http://markround.github.io/http_test"