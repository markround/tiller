Feature: Command line arguments

  @debug
  Scenario: Display executable path
    When I run `tiller -d`

  Scenario: Run tiller with no arguments
    When I run `tiller`
    Then the output should contain "Error: No configuration files present!"

  Scenario: Run tiller with -h
    When I successfully run `tiller -h`
    Then the output should contain "Usage: tiller"

  Scenario: Verbose mode
    When I successfully run `tiller -d -v -h`
    Then the output should contain ":verbose=>true"

  Scenario: Debug mode
    When I successfully run `tiller -d -h`
    Then the output should contain ":debug=>true"

  Scenario:API enable
    When I successfully run `tiller -d -a -h`
    Then the output should contain:
        """
        "api_enable"=>true
        """ 

  Scenario: Change API port
    When I successfully run `tiller -d -a -p 1234 -h`
    Then the output should contain:
        """
        "api_port"=>"1234"
        """

  Scenario: Set environment
    When I run `tiller -d -e test -h`
    Then the output should contain:
    """
    :environment=>"test"
    """

  Scenario: Enable md5 checks
  When I run `tiller -d --md5sum -h`
  Then the output should contain:
    """
    "md5sum"=>true
    """

  Scenario: Enable md5 noexec
    When I run `tiller -d --md5sum-noexec -h`
    Then the output should contain:
    """
    "md5sum_noexec"=>true
    """