require 'pp'

Then(/^an absolute file named "(.+)" should exist$/) do |file|
  File.exists?(file)
end

When(/^I have made the file "(.+)" executable"$/) do |file|
  File.chmod(0755, file)
end
