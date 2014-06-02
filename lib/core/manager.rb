
module Nucleon
class Manager
  
  include Parallel
    
  #-----------------------------------------------------------------------------
  
  @@supervisors  = {}
  @@environments = {}
  
  #-----------------------------------------------------------------------------
  # Plugin manager interface
  
  def self.connection(name = :core, reset = false)
    Nucleon.manager(@@supervisors, name, self, reset)
  end
  
  #---
  
  def initialize(actor_id, reset)
    @logger   = Nucleon.logger
    @actor_id = actor_id
    
    if reset || ! @@environments[@actor_id]
      @@environments[@actor_id] = Environment.new  
    end
  end
  
  #---
  
  attr_reader :logger
  
  #---
  
  def myself
    Nucleon.handle(self)
  end
  
  #---
  
  def test_connection
    true
  end
  
  #-----------------------------------------------------------------------------
  # Plugin model accessors / modifiers
  
  def namespaces
    @@environments[@actor_id].namespaces
  end
  
  #---
  
  def types(namespace)
    @@environments[@actor_id].plugin_types(namespace)
  end
  
  def define_type(namespace, plugin_type, default_provider)
    @@environments[@actor_id].define_plugin_type(namespace, plugin_type, default_provider)  
  end
  
  def define_types(namespace, type_info)
    @@environments[@actor_id].define_plugin_types(namespace, type_info) 
  end
  
  def type_defined?(namespace, plugin_type)
    @@environments[@actor_id].plugin_type_defined?(namespace, plugin_type)  
  end
  
  def type_default(namespace, plugin_type)
    @@environments[@actor_id].plugin_type_default(namespace, plugin_type)
  end
  
  #---
  
  def loaded_plugin(namespace, plugin_type, provider)
    @@environments[@actor_id].loaded_plugin(namespace, plugin_type, provider)  
  end
  
  def loaded_plugins(namespace = nil, plugin_type = nil, provider = nil)
    @@environments[@actor_id].loaded_plugins(namespace, plugin_type, provider)
  end
  
  def define_plugin(namespace, plugin_type, base_path, file, &code)
    @@environments[@actor_id].define_plugin(namespace, plugin_type, base_path, file, &code)  
  end
  
  def plugin_has_provider?(namespace, plugin_type, provider)
    @@environments[@actor_id].plugin_has_provider?(namespace, plugin_type, provider)  
  end
  
  #---
  
  def active_plugins(namespace = nil, plugin_type = nil, provider = nil)
    @@environments[@actor_id].active_plugins(namespace, plugin_type, provider)
  end 
  
  #-----------------------------------------------------------------------------
  # Plugin registration / initialization
  
  def reload(core = false, &code)
    logger.info("Loading Nucleon plugins at #{Time.now}")
    
    if core
      Celluloid.logger = logger if Nucleon.parallel?   
    
      define_types :nucleon, {
        :extension  => nil,     # Core
        :action     => :update, # Core
        :project    => :git,    # Core
        :command    => :bash,   # Core
        :event      => :regex,  # Utility
        :template   => :json,   # Utility
        :translator => :json    # Utility
      }
    end
    
    # Allow block level namespace and type registration
    code.call(:define, myself) if code
                              
    load_plugins(core, &code)                                  
    logger.info("Finished loading Nucleon plugins at #{Time.now}")    
  end
  
  #---
  
  def load_plugins(core = false, &code)
    if core    
      # Register core plugins
      logger.info("Initializing core plugins at #{Time.now}")
      register(File.join(File.dirname(__FILE__), '..'))
    end
    
    # Register external Gem defined plugins
    Gems.register(true)
    
    # Register any other extension plugins
    exec(:register_plugins)
    
    # Catch any block level requests before autoloading
    code.call(:load, myself) if code
        
    # Autoload all registered plugins
    autoload
  end
  protected :load_plugins
  
  #---
  
  def register(base_path, &code)
    namespaces.each do |namespace|
      namespace_path = File.join(base_path, namespace.to_s)
      register_namespace(namespace, namespace_path, &code)
    end
  end
  
  #---
  
  def register_namespace(namespace, base_path, &code)
    if File.directory?(base_path)
      logger.info("Loading files from #{base_path} at #{Time.now}")
      
      Dir.glob(File.join(base_path, '*.rb')).each do |file|
        logger.debug("Loading file: #{file}")
        require file
      end
      
      logger.info("Loading directories from #{base_path} at #{Time.now}")
      Dir.entries(base_path).each do |path|
        unless path.match(/^\.\.?$/)
          register_type(namespace, base_path, path, &code) if type_defined?(namespace, path)      
        end
      end
    end  
  end
  protected :register_namespace
  
  #---
  
  def register_type(namespace, base_path, plugin_type, &code)
    base_directory = File.join(base_path, plugin_type.to_s)
    
    if File.directory?(base_directory)
      logger.info("Registering #{base_directory} at #{Time.now}")
      
      Dir.glob(File.join(base_directory, '**', '*.rb')).each do |file|
        define_plugin(namespace, plugin_type, base_directory, file, &code)
      end
    end
  end
  protected :register_type
  
  #---
  
  def autoload
    logger.info("Autoloading registered plugins at #{Time.now}")
    
    load_info = loaded_plugins
    
    load_info.keys.each do |namespace|
      load_info[namespace].keys.each do |plugin_type|
        logger.debug("Autoloading type: #{plugin_type}")
      
        load_info[namespace][plugin_type].each do |provider, plugin|
          logger.debug("Autoloading provider #{provider} at #{plugin[:directory]}")
        
          require plugin[:file]
        
          load_info[namespace][plugin_type][provider][:class] = class_const(plugin[:class_components])
          logger.debug("Updated #{plugin_type} #{provider} load info")
        
          # Make sure extensions are listening from the time they are loaded
          if plugin[:namespace] == :nucleon && plugin_type == :extension 
            # Create a persistent instance
            load(plugin[:namespace], :extension, provider, { :name => provider })
          end 
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Plugin workflow
  
  def load_base(namespace, plugin_type, provider, options = {})
    logger.info("Fetching plugin #{namespace} #{plugin_type} provider #{provider} at #{Time.now}")
    
    type_info  = loaded_plugin(namespace, plugin_type, provider)
    options    = translate_type(type_info, options)    
    config     = Config.ensure(options)
    name       = config.get(:name, nil)
    ensure_new = config.delete(:new, false)
    
    if name
      logger.debug("Looking up existing instance of #{name}")
      
      if existing_instance = get(namespace, plugin_type, name)
        unless ensure_new
          config.export.each do |property_name, value|
            unless [ :name, :meta ].include?(property_name)
              existing_instance[property_name] = value  
            end
          end
          existing_instance.normalize(true)
      
          logger.debug("Using existing instance of #{plugin_type}, #{name}")
          return existing_instance
        end
      end
    end
    create(namespace, plugin_type, provider, options)   
  end
  
  #---
  
  def load(namespace, plugin_type, provider = nil, options = {})
    default_provider = type_default(namespace, plugin_type)
    
    # Allow options to override provider
    config   = Config.ensure(options)
    provider = config.delete(:provider, provider)
    provider = default_provider unless provider
    
    load_base(namespace, plugin_type, provider, config)
  end
  
  #---
  
  def load_multiple(namespace, plugin_type, data, build_hash = false, keep_array = false)
    logger.info("Fetching multiple plugins of #{plugin_type} at #{Time.now}")
    
    group = ( build_hash ? {} : [] )
    klass = plugin_class(namespace, plugin_type)   
    data  = klass.build_info(namespace, plugin_type, data) if klass.respond_to?(:build_info)
    
    data.each do |options|
      if plugin = load(namespace, plugin_type, options[:provider], options)
        if build_hash
          group[plugin.plugin_name] = plugin
        else
          group << plugin
        end
      end
    end
    return group.shift if ! build_hash && group.length == 1 && ! keep_array
    group  
  end
  
  #---
  
  def create(namespace, plugin_type, provider, options = {})
    @@environments[@actor_id].create_plugin(namespace, plugin_type, provider, options) do |type_info, plugin_options|
      logger.info("Creating new plugin #{provider} #{plugin_type}")
      
      plugin_options        = translate(type_info, plugin_options)
      plugin_options[:meta] = Config.new(type_info).import(Util::Data.hash(plugin_options[:meta]))
      plugin_options  
    end
  end
  
  #---
  
  def get(namespace, plugin_type, plugin_name)
    @@environments[@actor_id].get_plugin(namespace, plugin_type, plugin_name)
  end
  
  #---
  
  def remove(plugin)
    if plugin && plugin.respond_to?(:plugin_type)
      @@environments[@actor_id].remove_plugin(plugin.plugin_namespace, plugin.plugin_type, plugin.plugin_instance_name) do
        logger.debug("Removing #{plugin.plugin_type} #{plugin.plugin_name}")
      
        plugin.remove_plugin
        plugin.terminate if plugin.respond_to?(:terminate) # For Celluloid plugins  
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Extension hook execution
 
  def exec(method, options = {})
    results = nil
    
    if Nucleon.log_level == :hook # To save processing on rendering
      logger.hook("Executing extension hook #{Nucleon.blue(method)} at #{Nucleon.green(Time.now.to_s)}")
    end
    
    extensions = active_plugins(:nucleon, :extension)
    
    extensions.each do |name, plugin|
      provider = plugin.plugin_provider
      result   = nil      
      
      logger.debug("Checking extension #{provider}")
      
      if plugin.respond_to?(method)
        results = {} if results.nil?       
        
        result = plugin.send(method, options)
        logger.info("Completed hook #{method} at #{Time.now} with: #{result.inspect}")
                    
        if block_given?
          results[provider] = yield(:process, result)
          logger.debug("Processed extension result into: #{results[provider].inspect}")  
        end
        
        if results[provider].nil?
          logger.debug("Setting extension result to: #{result.inspect}") 
          results[provider] = result
        end
      end
    end
    
    if ! results.nil? && block_given? 
      results = yield(:reduce, results)
      logger.debug("Reducing extension results to: #{results.inspect}")
    else
      logger.debug("Final extension results: #{results.inspect}")     
    end        
    results    
  end
  
  #---
  
  def config(type, options = {})
    config = Config.ensure(options)
    
    logger.debug("Generating #{type} extended configuration from: #{config.export.inspect}")
      
    exec("#{type}_config", Config.new(config.export)) do |op, data|
      if op == :reduce
        data.each do |provider, result|
          config.import(result)
        end
        nil
      else
        data
      end
    end    
    config.delete(:extension_type)
     
    logger.debug("Final extended configuration: #{config.export.inspect}")
    config 
  end
  
  #---
  
  def check(method, options = {})
    config = Config.ensure(options)
    
    logger.debug("Checking extension #{method} given: #{config.export.inspect}")
    
    success = exec(method, config.import({ :extension_type => :check })) do |op, data|
      if op == :reduce
        ! data.values.include?(false)
      else
        data ? true : false
      end
    end
    
    success = success.nil? || success ? true : false
    
    logger.debug("Extension #{method} check result: #{success.inspect}")      
    success
  end
  
  #---
  
  def value(method, value, options = {})
    config = Config.ensure(options)
    
    logger.debug("Setting extension #{method} value given: #{value.inspect}")
    
    exec(method, config.import({ :value => value, :extension_type => :value })) do |op, data|
      if op == :process
        value = data unless data.nil?  
      end
    end
    
    logger.debug("Extension #{method} retrieved value: #{value.inspect}")
    value
  end
  
  #---
  
  def collect(method, options = {})
    config = Config.ensure(options)
    values = []
    
    logger.debug("Collecting extension #{method} values")
    
    exec(method, config.import({ :extension_type => :collect })) do |op, data|
      if op == :process
        values << data unless data.nil?  
      end
    end
    values = values.flatten
    
    logger.debug("Extension #{method} collected values: #{values.inspect}")  
    values
  end
       
  #-----------------------------------------------------------------------------
  # Utilities
  
  def translate_type(type_info, options)
    if type_info
      klass = plugin_class(type_info[:namespace], type_info[:type])
      logger.debug("Executing option translation for: #{klass.inspect}")          
    
      options = klass.send(:translate, options) if klass.respond_to?(:translate)
    end
    options
  end
  
  #---
  
  def translate(type_info, options)
    if type_info
      klass = type_info[:class]
    
      logger.debug("Executing option translation for: #{klass.inspect}")
              
      options = klass.send(:translate, options) if klass.respond_to?(:translate)
    end
    options
  end
  
  #---
  
  def class_name(name, separator = '::', want_array = FALSE)
    @@environments[@actor_id].class_name(name, separator, want_array)
  end
  
  #---
  
  def class_const(name, separator = '::')
    @@environments[@actor_id].class_const(name, separator)
  end
  
  #---
  
  def plugin_class(namespace, plugin_type)
    @@environments[@actor_id].plugin_class(namespace, plugin_type)
  end
end
end
