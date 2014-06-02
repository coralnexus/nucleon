
module Nucleon
module Event
class Regex < Nucleon.plugin_class(:nucleon, :event)
 
  #-----------------------------------------------------------------------------
  # Regular expression event interface
  
  def normalize(reload)
    super
    
    if get(:string)
      myself.pattern = delete(:string)
    end
  end
      
  #-----------------------------------------------------------------------------
  # Property accessors / modifiers
  
  def pattern(default = '')
    return get(:pattern, default)
  end
  
  #---
   
  def pattern=pattern
    set(:pattern, string(pattern))  
  end
  
  #-----------------------------------------------------------------------------
  # Operations
  
  def render
    return "#{name}:#{pattern}"
  end
  
  #---
   
  def check(source)
    if pattern.empty?
      logger.warn("Can not check regex pattern because it is empty")
    else
      success = source.match(/#{pattern}/)
      
      logger.debug("Checking regex event with pattern #{pattern}: #{success.inspect}")
      return success
    end
    return true
  end
end
end
end
