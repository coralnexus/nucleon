
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
    plugin_path = File.join(spec.full_gem_path, 'lib', 'nucleon')
    if File.directory?(plugin_path)
      logger.info("Registering gem #{spec.name} at #{plugin_path} at #{Time.now}")
      
      @@gems[spec.name] = {
        :lib_dir => plugin_path,
        :spec    => spec
      }
      if spec.name == 'nucleon'
        logger.debug("Setting Nucleon core gemspec")
        @@core = spec
      else
        Manager.connection.register(plugin_path) # Autoload plugins and related files  
      end      
    end  
  end
end
end