Feature: Plugin API versioning

  Background:
    Given a directory named "lib/tiller/data"
    And a file named "lib/tiller/data/version.rb" with:
    """
    class VersioningTestPlugin < Tiller::DataSource
      @plugin_api_versions = [ 1000 ]
    end
    """

  Scenario: Test plugin with unsupported API
    Given a file named "common.yaml" with:
    """
    ---
    data_sources: [ 'environment' , 'file' , 'version' ]
    template_sources: [ 'file' ]
    environments:
      development: {}
    """
    When I run `tiller -vd -b . -l ./lib`
    Then the output should contain "ERROR : Plugin VersioningTestPlugin does not support specified API version"

  Scenario: Test plugin with unsupported API set via CLI
    Given a file named "common.yaml" with:
    """
    ---
    data_sources: [ 'environment' , 'file' , 'version' ]
    template_sources: [ 'file' ]
    environments:
      development: {}
    """
    When I run `tiller -vd -b . -l ./lib --plugin-api-version 1000`
    Then the output should contain "ERROR : Plugin EnvironmentDataSource does not support specified API version"

  Scenario: Test plugin with unsupported API set via config file
    Given a file named "common.yaml" with:
    """
    ---
    plugin_api_version: 1000
    data_sources: [ 'environment' , 'file' , 'version' ]
    template_sources: [ 'file' ]
    environments:
      development: {}
    """
    When I run `tiller -vd -b . -l ./lib`
    Then the output should contain "ERROR : Plugin EnvironmentDataSource does not support specified API version"