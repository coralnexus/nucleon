
module Nucleon
module Plugin
class Template < Base

  #-----------------------------------------------------------------------------
  # Template plugin interface

  
  #-----------------------------------------------------------------------------
  # Property accessor / modifiers

  #-----------------------------------------------------------------------------
  # Operations
  
  def process(value)
    case value
    when String, Symbol
      return nil        if Util::Data.undef?(value)
      return 'false'    if value == false
      return 'true'     if value == true      
      return value.to_s if value.is_a?(Symbol)
      
    when Hash
      results = {}
      value.each do |key, item|
        result = process(item)
        unless result.nil?
          results[key] = result  
        end
        value = results
      end
      
    when Array
      results = []
      value.each_with_index do |item, index|
        result = process(item)
        unless result.nil?
          results << result  
        end        
      end
      value = results
    end
    return value
  end
    
  #---
  
  def render(data)
    normalize   = get(:normalize_template, true)
    interpolate = get(:interpolate_template, true)
    
    logger.debug("Rendering data: normalize: #{normalize.inspect}; interpolate: #{interpolate.inspect}: #{data.inspect}")
    
    if normalize
      data = Config.normalize(data, nil, export)
      logger.debug("Pre-rendering data normalization: #{data.inspect}")
    end
    
    if normalize && interpolate
      data = Util::Data.interpolate(data, data, export)
      logger.debug("Pre-rendering data interpolation: #{data.inspect}")
    end    
    return render_processed(process(data))
  end
  
  #---
  
  def render_processed(data)
    logger.debug("Rendering #{plugin_provider} data: #{data.inspect}")
    
    output = ''
    output = yield(output) if block_given?
    
    logger.debug("Completed rendering of #{plugin_provider} data: #{output}")
    return output
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def self.translate(data)
    return data
  end
end
end
end
