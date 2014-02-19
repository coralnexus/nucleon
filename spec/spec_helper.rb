
require 'rspec'
require 'stringio'
require 'coral_core'

require 'coral_test_kernel'
require 'coral_mock_input'

#-------------------------------------------------------------------------------

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.color_enabled  = true
  config.formatter      = 'documentation'
end