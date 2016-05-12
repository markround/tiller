require 'aruba/cucumber'

Around('@slow') do |scenario, block|
  Timeout.timeout(5.0) do
    block.call
  end
end
