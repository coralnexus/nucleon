
module Nucleon
class Config
class Collection

  #-----------------------------------------------------------------------------
  # Property accessor / modifiers

  @@lock       = Mutex.new
  @@properties = {}
  
  #---
  
  def self.all
    @@properties
  end
  
  #---
  
  def self.get(name)
    value = nil
    @@lock.synchronize do
      value = @@properties[name.to_sym]
    end
    value
  end
  
  #---
  
  def self.set(name, value)
    @@lock.synchronize do
      @@properties[name.to_sym] = value
    end
  end
  
  #---
  
  def self.delete(name)
    @@lock.synchronize do
      @@properties.delete(name.to_sym)
    end
  end
   
  #---
  
  def self.clear
    @@lock.synchronize do
      @@properties = {}
    end
  end
  
  #---
  
  def self.save(options = {})
    unless Util::Data.empty?(options[:log_dir])
      @@lock.synchronize do
        log_dir = options[:log_dir]
      
        if options[:config_store]
          unless File.directory?(log_dir)
            FileUtils.mkdir_p(log_dir)
          end
          Util::Disk.write(File.join(log_dir, "properties.json"), Util::Data.to_json(@@properties, true))
          Util::Disk.write(File.join(log_dir, "properties.yaml"), Util::Data.to_yaml(Util::Data.string_map(@@properties)))
        end
      end
    end
  end
end
end
end
