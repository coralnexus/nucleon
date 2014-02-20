
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
  
  def self.save
    log_options = Options.get(:nucleon_log)
    
    unless Util::Data.empty?(log_options[:config_log])
      config_log = log_options[:config_log]
      
      if log_options[:config_store]
        Util::Disk.write(config_log, MultiJson.dump(@@properties, :pretty => true))
        Util::Disk.close(config_log)
      end
    end
  end
end
end
end
