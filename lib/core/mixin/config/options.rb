
# Should be included via extend
#
# extend Mixin::ConfigOptions
#

module Nucleon
module Mixin
module ConfigOptions
  
  #-----------------------------------------------------------------------------
  # Configuration options interface
  
  def contexts(contexts = [], hierarchy = [])
    return Config::Options.contexts(contexts, hierarchy)  
  end
  
  #---
  
  def get_options(contexts, force = true)
    return Config::Options.get(contexts, force)  
  end
  
  #---
  
  def set_options(contexts, options, force = true)
    Config::Options.set(contexts, options, force)
    return self  
  end
  
  #---
  
  def clear_options(contexts)
    Config::Options.clear(contexts)
    return self  
  end
end
end
end
