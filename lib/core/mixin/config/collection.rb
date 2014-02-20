
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
    return Config::Collection.all
  end
  
  #---
  
  def get_property(name)
    return Config::Collection.get(name)
  end
  
  #---
  
  def set_property(name, value)
    Config::Collection.set(name, value)
    return self  
  end
  
  #---
  
  def delete_property(name)
    Config::Collection.delete(name)
    return self
  end
  
  #---
  
  def clear_properties
    Config::Collection.clear
    return self  
  end
  
  #---
  
  def save_properties
    Config::Collection.save
    return self
  end
end
end
end
