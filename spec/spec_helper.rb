
require 'rspec'
require 'stringio'
require 'nucleon'

require 'nucleon_test'
require 'nucleon_codes'
require 'nucleon_config'
require 'nucleon_plugin'

#*******************************************************************************

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.color          = true
  config.formatter      = 'documentation'
end