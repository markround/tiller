When /^I start my daemon with "([^"]*)"$/ do |cmd|
  @root = Pathname.new(File.dirname(__FILE__)).parent.parent.expand_path
  command = "#{@root.join('bin')}/#{cmd}"

  @pipe = IO.popen(cmd, "r")
  sleep 3 # so the daemon has a chance to boot

  # clean up the daemon when the tests finish
  at_exit do
    Process.kill("KILL", @pipe.pid)
  end
end

Then /^a daemon called "([^"]*)" should be running$/ do |daemon|
    expect(`pgrep #{daemon}`.size).to be > 0
end