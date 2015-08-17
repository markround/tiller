# Don't uppercase environment variables
Given(/^I set the environment variables? exactly to:/) do |table|
  table.hashes.each do |row|
    variable = row['variable'].to_s
    value = row['value'].to_s

    set_environment_variable(variable, value)
  end
end