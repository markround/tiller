require 'aruba/cucumber'
require 'tiller/version'

# Only run tests on unsupported versions of Ruby.
# E.g. to make sure the deprecation warning appears.
Around ('@unsupported_ruby') do |scenario, block|
  if RUBY_VERSION < SUPPORTED_RUBY_VERSION
    block.call
  else
    skip_this_scenario
  end
end

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
