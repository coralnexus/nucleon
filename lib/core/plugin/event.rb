
module Nucleon
module Plugin
class Event < Base

  #-----------------------------------------------------------------------------
  # Event plugin interface

  
  #-----------------------------------------------------------------------------
  # Property accessor / modifiers

  #-----------------------------------------------------------------------------
  # Operations
  
  def render
    return name
  end
  
  #---
 
  def check(source)
    # Implement in sub classes
    return true
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def self.build_info(type, data)  
    data = data.split(/\s*,\s*/) if data.is_a?(String)
    return super(type, data)
  end
  
  #---
   
  def self.translate(data)
    options = super(data)
    
    case data        
    when String
      components = data.split(':')
      
      options[:provider] = components.shift
      options[:string]   = components.join(':')
      
      logger.debug("Translating event options: #{options.inspect}") 
    end
    return options  
  end
end
end
end
