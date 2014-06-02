
module Nucleon
module Plugin
class Command < Nucleon.plugin_class(:nucleon, :base)

  #-----------------------------------------------------------------------------
  # Command plugin interface
  
  def normalize(reload)
    super
  end
  
  #---
   
  def to_s
    return build(export)
  end
  
  #-----------------------------------------------------------------------------
  # Property accessor / modifiers
  
  def command(default = '')
    return string(get(:command, default))
  end
  
  #---
  
  def command=command
    set(:command, string(command))
  end
  
  #---
  
  def args(default = [])
    return array(get(:args, default)) 
  end
  
  #---
  
  def args=args
    set(:args, array(args))
  end
  
  #---
  
  def flags(default = [])
    return array(get(:flags, default)) 
  end
  
  #---
  
  def flags=flags
    set(:flags, array(flags))
  end
  
  #---
  
  def data(default = {})
    return hash(get(:data, default)) 
  end
  
  #---
  
  def data=data
    set(:data, hash(data))
  end
  
  #---
  
  def subcommand=subcommand
    unless Util::Data.empty?(subcommand)
      set(:subcommand, new(hash(subcommand)))
    end
  end
  
  #-----------------------------------------------------------------------------
  # Command operations
  
  def build(components = {}, overrides = nil, override_key = false)
    logger.debug("Building command with #{components.inspect}")
    logger.debug("Overrides: #{overrides.inspect}")
    logger.debug("Override key: #{override_key}")
    
    return '' # Implement in sub classes
  end
  
  #---
  
  def exec(options = {}, overrides = nil)
    logger.debug("Executing command with #{options.inspect}")
    logger.debug("Overrides: #{overrides.inspect}")
    
    # Implement in sub classes (don't forget the yield!)
    return true
  end
end
end
end
