
module Nucleon
module Gems
  
  #-----------------------------------------------------------------------------
  
  @@core = nil
  @@gems = {}
  
  #-----------------------------------------------------------------------------
  # Gem interface
  
  def self.logger
    Core.logger
  end
  
  #---
    
  def self.core
    @@core
  end
  
  #---
  
  def self.registered
    @@gems
  end
  
  #---
  
  def self.register(reset = false)
    if reset || Util::Data.empty?(@@gems)
      logger.info("Registering external gem defined Nucleon plugins at #{Time.now}")
      
      if defined?(Gem) 
        if ! defined?(Bundler) && Gem::Specification.respond_to?(:latest_specs)
          logger.debug("Not using bundler")
          Gem::Specification.latest_specs(true).each do |spec|
            register_gem(spec)
          end
        else
          logger.debug("Using bundler or Gem specification without latest_specs")
          Gem.loaded_specs.each do |name, spec|
            register_gem(spec)
          end     
        end
      end
    end
    @@gems
  end
  
  #---
  
  def self.register_gem(spec)
    name      = spec.name
    base_path = File.join(spec.full_gem_path, 'lib')
    
    Manager.connection.register(base_path) do |data|      
      namespace   = data[:namespace]
      plugin_path = data[:directory]
      
      logger.info("Registering gem #{name} at #{plugin_path} at #{Time.now}")
      
      unless @@gems.has_key?(name)
        @@gems[name] = { 
          :spec       => spec, 
          :base_path  => base_path, 
          :namespaces => [] 
        }
      end 
      @@gems[name][:namespaces] << namespace unless @@gems[name][:namespaces].include?(namespace)
      
      if name == 'nucleon'
        logger.debug("Setting Nucleon core gemspec")
        @@core = spec
      end  
    end
  end
end
end
