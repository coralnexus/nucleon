
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
  
  def self.register(reset = false, loaded = [])
    if reset || Util::Data.empty?(@@gems)
      logger.info("Registering external gem defined Nucleon plugins at #{Time.now}")
      
      each_gem do |spec|
        register_gem(spec, loaded)
      end
    end
    @@gems
  end
  
  #---
  
  def self.register_gem(spec, loaded = [])
    name      = spec.name.to_sym
    base_path = File.join(spec.full_gem_path, 'lib')
    
    if name == :nucleon
      logger.debug("Setting Nucleon core gemspec")
      @@core       = spec      
      @@gems[name] = { 
        :spec       => spec, 
        :base_path  => base_path, 
        :namespaces => [ :nucleon ] 
      } 
    else
      Manager.connection.register(base_path) do |data|
        namespace   = data[:namespace]
        plugin_path = data[:directory]
        
        unless @@gems.has_key?(name)
          logger.info("Registering gem #{name} at #{plugin_path} at #{Time.now}")
          
          unless loaded.include?(name)          
            loader = File.join(base_path, "#{name}.rb")
            require loader if File.exists?(loader)
          end
        end 
        
        @@gems[name] = { 
          :spec       => spec, 
          :base_path  => base_path, 
          :namespaces => [] 
        }
        @@gems[name][:namespaces] << namespace unless @@gems[name][:namespaces].include?(namespace)
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def self.each_gem(&block)
    if defined?(Gem) 
      if ! defined?(Bundler) && Gem::Specification.respond_to?(:latest_specs)
        logger.debug("Not using bundler")
        Gem::Specification.latest_specs(true).each do |spec|
          block.call(spec)
        end
      else
        logger.debug("Using bundler or Gem specification without latest_specs")
        Gem.loaded_specs.each do |name, spec|
          block.call(spec)
        end     
      end
    end
  end
  
  #---
  
  def self.exist?(*names)
    checks = Hash[names.map{|name| [ name.to_s, true ] }]
    each_gem do |spec|
      checks.delete(spec.name.to_s)
    end
    checks.empty? ? true : false
  end
  
  #---
  
  def self.specs(*names)
    checks = Hash[names.map{|name| [ name.to_s, true ] }]
    specs  = []
    
    each_gem do |spec|
      if checks.has_key?(spec.name.to_s)
        specs << spec
      end
    end
    specs
  end
  
  #---
  
  def self.spec(name)
    results = specs(name)
    return results[0] unless results.empty?
    nil
  end
end
end
