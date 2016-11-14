require 'aruba/cucumber'

Around('@ruby21') do |scenario, block|
  if RUBY_VERSION < "2.1.0"
    skip_this_scenario
  else
    block.call
  end
end

Around('@ruby2') do |scenario, block|
  if RUBY_VERSION < "2.0.0"
    skip_this_scenario
  else
    block.call
  end
end
