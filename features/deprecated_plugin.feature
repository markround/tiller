Feature: Deprecated plugins

  Background:
    Given a directory named "lib/tiller/data"
    And a file named "lib/tiller/data/deprecated.rb" with:
    """
    class DeprecationTestPlugin < Tiller::DataSource
    def setup
      self.deprecated
    end
    end
    """    

  Scenario: Test plugin with unsupported API
    Given a file named "common.yaml" with:
    """
    ---
    data_sources: [ 'file' , 'deprecated' ]
    template_sources: [ 'file' ]
    environments:
      development: {}
    """
    When I run `tiller -vd -b . -l ./lib`
    Then the output should contain "This plugin is deprecated and will be removed in a future release"