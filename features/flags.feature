Feature: Command line arguments
  Scenario: Run tiller with -h
    When I successfully run `tiller -h`
    Then the output should contain "Usage: tiller"

  Scenario: Verbose mode
    When I successfully run `tiller -v -h`
    Then the output should contain ":verbose=>true"

  Scenario: Debug mode
    When I successfully run `tiller -d -h`
    Then the output should contain ":debug=>true"

  Scenario:API enable
    When I successfully run `tiller -a -h`
    Then the output should contain:
        """
        "api_enable"=>true
        """ 

  Scenario: Change API port
    When I successfully run `tiller -a -p 1234 -h`
    Then the output should contain:
        """
        "api_port"=>"1234"
        """

  Scenario: Set environment
    When I run `tiller -e test -h`
    Then the output should contain:
    """
:environment=>"test"
"""