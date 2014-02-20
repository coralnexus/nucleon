
module Nucleon
module Plugin
class Translator < Base

  #-----------------------------------------------------------------------------
  # Translator plugin interface
  
  #-----------------------------------------------------------------------------
  # Property accessor / modifiers

  #-----------------------------------------------------------------------------
  # Operations
  
  def parse(raw)
    logger.debug("Parsing raw data: #{raw}")
    
    properties = {}
    properties = yield(properties) if block_given?
    
    logger.debug("Completed parsing data: #{properties.inspect}")
    return properties
  end
  
  #---
  
  def generate(properties)
    logger.debug("Generating output data: #{properties.inspect}")
    
    output = ''
    output = yield(output) if block_given?
    
    logger.debug("Completed generating data: #{output}")
    return output
  end
end
end
end
