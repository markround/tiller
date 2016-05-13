require 'aruba/cucumber'

Around('@slow') do |scenario, block|
  Timeout.timeout(10.0) do
    block.call
  end
end
