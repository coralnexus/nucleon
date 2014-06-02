
module Nucleon
module Plugin
class Event < Nucleon.plugin_class(:nucleon, :base)

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
  
  def self.build_info(namespace, plugin_type, data)  
    data = data.split(/\s*,\s*/) if data.is_a?(String)
    return super(namespace, plugin_type, data)
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
