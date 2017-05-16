Feature: Deprecation warnings

  @unsupported_ruby
  Scenario: Display deprecation warning
    When I successfully run `tiller -h`
    Then the output should match /Warning : Support for Ruby versions < ([0-9]\.?){3} is deprecated./
    And the output should contain "See http://tiller.readthedocs.io/en/latest/requirements/"