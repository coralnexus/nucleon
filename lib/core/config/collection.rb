
module Nucleon
class Config
class Collection

  #-----------------------------------------------------------------------------
  # Property accessor / modifiers

  @@properties = {}
  
  #---
  
  def self.all
    return @@properties
  end
  
  #---
  
  def self.get(name)
    return @@properties[name.to_sym]
  end
  
  #---
  
  def self.set(name, value)
    @@properties[name.to_sym] = value
  end
  
  #---
  
  def self.delete(name)
    @@properties.delete(name.to_sym)
  end
   
  #---
  
  def self.clear
    @@properties = {}
  end
  
  #---
  
  def self.save(options = {})
    unless Util::Data.empty?(options[:config_log])
      config_log = options[:config_log]
      
      if options[:config_store]
        Util::Disk.write(config_log, Util::Data.to_json(@@properties, true))
      end
    end
  end
end
end
end
