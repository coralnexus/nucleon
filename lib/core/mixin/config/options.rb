
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
    Config::Options.contexts(contexts, hierarchy)  
  end
  
  #---
  
  def all_options
    Config::Options.all
  end
  
  #---
  
  def get_options(contexts, force = true)
    Config::Options.get(contexts, force)  
  end
  
  #---
  
  def set_options(contexts, options, force = true)
    Config::Options.set(contexts, options, force)
  end
  
  #---
  
  def clear_options(contexts)
    Config::Options.clear(contexts)
  end
end
end
end
