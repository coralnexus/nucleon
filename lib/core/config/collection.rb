
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
    unless Util::Data.empty?(options[:log_dir])
      log_dir = options[:log_dir]
      
      if options[:config_store]
        unless File.directory?(log_dir)
          FileUtils.mkdir_p(log_dir)
        end
        Util::Disk.write(File.join(log_dir, "common.json"), Util::Data.to_json(@@properties, true))
        Util::Disk.write(File.join(log_dir, "common.yaml"), Util::Data.to_yaml(Util::Data.string_map(@@properties)))
      end
    end
  end
end
end
end
