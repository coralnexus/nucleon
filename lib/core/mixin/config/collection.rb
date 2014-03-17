
# Should be included via extend
#
# extend Mixin::ConfigCollection
#

module Nucleon
module Mixin
module ConfigCollection

  #-----------------------------------------------------------------------------
  # Configuration collection interface
  
  def all_properties
    Config::Collection.all
  end
  
  #---
  
  def get_property(name)
    Config::Collection.get(name)
  end
  
  #---
  
  def set_property(name, value)
    Config::Collection.set(name, value)
  end
  
  #---
  
  def delete_property(name)
    Config::Collection.delete(name)
  end
  
  #---
  
  def clear_properties
    Config::Collection.clear
  end
  
  #---
  
  def save_properties(options = {})
    Config::Collection.save(options)
  end
end
end
end
