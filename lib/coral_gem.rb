
home = File.dirname(__FILE__)

$:.unshift(home) unless
  $:.include?(home) || $:.include?(File.expand_path(home))
  
#-------------------------------------------------------------------------------
  
require 'rubygems'
require 'coral_core'

#---

# Include data model
[ ].each do |name| 
  require File.join('coral_gem', name.to_s + '.rb') 
end

#*******************************************************************************
# Coral Starter Gem
#
# This provides a starter scaffolding Gem for further development
#
# Author::    Adrian Webb (mailto:adrian.webb@coraltech.net)
# License::   GPLv3
module Coral
  
  #-----------------------------------------------------------------------------
  # Constructor / Destructor
  
  #-----------------------------------------------------------------------------
  # Accessors / Modifiers

#*******************************************************************************

module Gem
  
  VERSION = File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))
  
  #-----------------------------------------------------------------------------
  # Constructor / Destructor
  
  #-----------------------------------------------------------------------------
  # Accessors / Modifiers

end
end