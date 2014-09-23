
require 'rspec'
require 'stringio'
require 'nucleon'

require 'coral_test_kernel'
require 'coral_mock_input'

#-------------------------------------------------------------------------------

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.color          = true
  config.formatter      = 'documentation'
end