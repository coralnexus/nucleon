
module Nucleon
class Manager
  
  include Celluloid
  
  #-----------------------------------------------------------------------------
  
  @@supervisors = {}
  
  #-----------------------------------------------------------------------------
  # Plugin manager interface
  
  def self.init_manager(name)
    name = name.to_sym
    
    Manager.supervise_as name
    @@supervisors[name] = Celluloid::Actor[name]  
  end
  
  #---
  
  def self.connection(name = :core)
    name = name.to_sym
    
    init_manager(name) unless @@supervisors.has_key?(name)
    
    begin
      @@supervisors[name].test_connection
    rescue Celluloid::DeadActorError
      retry
    end
    @@supervisors[name]
  end
  
  #---
  
  def initialize
    @logger = Nucleon.logger
    
    @namespaces = {}
    @types      = {}
    @load_info  = {}    
    @plugins    = {}
  end
  
  #-----------------------------------------------------------------------------
  # Property accessor / modifiers
  
  attr_reader :logger
  
  #---
  
  def namespaces
    @namespaces.keys
  end
  
  def define_namespace(*namespaces)
    namespaces.each do |namespace|
      @namespaces[namespace.to_sym] = true
    end  
  end
  
  #---
  
  def types
    @types.keys
  end
  
  #---
  
  def type_default(type)
    @types[type.to_sym]
  end
  
  #---
  
  def loaded_plugins(type = nil, provider = nil)
    results  = {}
    type     = type.to_sym if type
    provider = provider.to_sym if provider
    
    if type && @load_info.has_key?(type)
      if provider && @load_info.has_key?(provider)
        results = @load_info[type][provider]  
      else
        results = @load_info[type]
      end
    elsif ! type
      results = @load_info      
    end
    results
  end
 
  #---
  
  def plugins(type = nil, provider = nil)
    results  = {}
    type     = type.to_sym if type
    provider = provider.to_sym if provider
    
    if type && @plugins.has_key?(type)
      if provider && ! @plugins[type].keys.empty?
        @plugins[type].each do |instance_name, plugin|
          plugin                 = @plugins[type][instance_name]
          results[instance_name] = plugin if plugin.plugin_provider == provider
        end
      else
        results = @plugins[type]
      end
    elsif ! type
      results = @plugins
    end    
    results
  end 
  
  #-----------------------------------------------------------------------------
  # Operations
  
  def test_connection
    true
  end
  
  #---
  
  def reload(core = false, &code)
    logger.info("Loading Nucleon plugins at #{Time.now}")
    
    if core       
      Celluloid.logger = logger    
    
      define_namespace :nucleon
    
      define_type :extension     => nil,     # Core
                  :action        => :update, # Core
                  :project       => :git,    # Core
                  :command       => :bash,   # Core
                  :event         => :regex,  # Utility
                  :template      => :json,   # Utility
                  :translator    => :json    # Utility
    end
    
    # Allow block level namespace and type registration
    code.call(:define, myself) if code
                              
    load_plugins(core, &code)                                  
    logger.info("Finished loading Nucleon plugins at #{Time.now}")    
  end
  
  #---
  
  def define_type(type_info)
    if type_info.is_a?(Hash)
      logger.info("Defining plugin types at #{Time.now}")
      
      type_info.each do |type, default_provider|
        logger.debug("Mapping plugin type #{type} to default provider #{default_provider}")
        @types[type.to_sym] = default_provider
      end
    else
      logger.warn("Defined types must be specified as a hash to be registered properly")      
    end
  end
  
  #---
  
  def load_plugins(core = false, &code)
    if core    
      # Register core plugins
      logger.info("Initializing core plugins at #{Time.now}")
      register(File.join(File.dirname(__FILE__), '..'))
        
      # Register external Gem defined plugins
      Gems.register(true)
    end
    
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
      
      if File.directory?(namespace_path)
        register_namespace(namespace, namespace_path, &code)  
      end
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
          register_type(namespace, base_path, path, &code) if types.include?(path.to_sym)      
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
      
      Dir.glob(File.join(base_directory, '*.rb')).each do |file|
        add_build_info(namespace, plugin_type, file)
      end
    end
  end
  protected :register_type
  
  #---
 
  def add_build_info(namespace, type, file, &code)
    type = type.to_sym
    
    @load_info[type] = {} unless @load_info.has_key?(type)
    
    components = file.split(File::SEPARATOR)
    provider   = components.pop.sub(/\.rb/, '').to_sym
    directory  = components.join(File::SEPARATOR) 
    
    logger.info("Loading nucleon #{type} plugin #{provider} at #{Time.now}")
        
    unless @load_info[type].has_key?(provider)
      data = {
        :namespace => namespace,
        :type      => type,
        :provider  => provider,        
        :directory => directory,
        :file      => file
      }      
      code.call(data) if code
      
      logger.debug("Plugin #{type} loaded: #{data.inspect}")
      @load_info[type][provider] = data
    end
  end
  protected :add_build_info
  
  #---
  
  def autoload
    logger.info("Autoloading registered plugins at #{Time.now}")
    
    @load_info.keys.each do |type|
      logger.debug("Autoloading type: #{type}")
      
      @load_info[type].each do |provider, plugin|
        logger.debug("Autoloading provider #{provider} at #{plugin[:directory]}")
        
        nucleon_require(plugin[:directory], provider)
        
        @load_info[type][provider][:class] = provider_class(plugin[:namespace], type, provider)
        logger.debug("Updated #{type} #{provider} load info: #{@load_info[type][provider].inspect}")
        
        # Make sure extensions are listening from the time they are loaded
        load(:extension, provider, { :name => provider }) if type == :extension # Create a persistent instance
      end
    end
  end
  
  #---
  
  def load(type, provider = nil, options = {})
    config = Config.ensure(options)
    name   = config.get(:name, nil)
    
    logger.info("Fetching plugin #{type} provider #{provider} at #{Time.now}")
    logger.debug("Plugin options: #{config.export.inspect}")
    
    default_provider = type_default(type)
    
    if options.is_a?(Hash) || options.is_a?(Nucleon::Config)      
      config   = Config.ensure(translate_type(type, options))           
      provider = config.get(:provider, provider)
      options  = config.export
    end
    provider = default_provider unless provider
    
    if name
      logger.debug("Looking up existing instance of #{name}")
      
      existing_instance = get(type, name)
      logger.info("Using existing instance of #{type}, #{name}") if existing_instance
    end
    
    return existing_instance if existing_instance
    create(type, provider, config.export)  
  end
  
  #---
  
  def load_multiple(type, data, build_hash = false, keep_array = false)
    logger.info("Fetching multiple plugins of #{type} at #{Time.now}")
    
    group = ( build_hash ? {} : [] )
    klass = plugin_class(type)   
    data  = klass.build_info(type, data) if klass.respond_to?(:build_info)
    
    logger.debug("Translated plugin data: #{data.inspect}")
    
    data.each do |options|
      if plugin = load(type, options[:provider], options)
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
  
  def create(type, provider, options = {})
    type     = type.to_sym
    provider = provider.to_sym
       
    unless @types.has_key?(type)
      logger.warn("Plugin type #{type} creation requested but it has not been registered yet")
      return nil
    end
    
    info = @load_info[type][provider] if Util::Data.exists?(@load_info, [ type, provider ])
        
    if info
      logger.debug("Plugin information for #{provider} #{type} found.  Data: #{info.inspect}")
      
      instance_name = "#{provider}_" + Nucleon.sha1(options)
      options       = translate(info[:namespace], type, provider, options)      
              
      @plugins[type] = {} unless @plugins.has_key?(type)
      
      unless instance_name && @plugins[type].has_key?(instance_name)
        info[:instance_name] = instance_name
        options[:meta]       = Config.new(info).import(Util::Data.hash(options[:meta]))
        
        logger.info("Creating new plugin #{provider} #{type} with #{options.inspect}")
       
        plugin = info[:class].new(type, provider, options)
        
        @plugins[type][instance_name] = plugin 
      end
      return @plugins[type][instance_name]
    end
    
    logger.warn("Plugin information cannot be found for plugin #{type} #{provider}")      
    nil  
  end
  
  #---
  
  def get(type, name)
    logger.info("Fetching plugin #{type} #{name}")
    
    if @plugins.has_key?(type)
      @plugins[type].each do |instance_name, plugin|
        if plugin.plugin_name.to_s == name.to_s
          logger.debug("Plugin #{type} #{name} found")
          return plugin
        end
      end
    end
    logger.debug("Plugin #{type} #{name} not found")
    nil  
  end
  
  #---
  
  def remove(plugin)
    if plugin && plugin.respond_to?(:plugin_type) && @plugins.has_key?(plugin.plugin_type)
      logger.debug("Removing #{plugin.plugin_type} #{plugin.plugin_name}")
      @plugins[plugin.plugin_type].delete(plugin.plugin_instance_name)
      plugin.terminate if plugin.respond_to?(:terminate)
    else
      logger.warn("Cannot remove plugin: #{plugin.inspect}")    
    end
  end
  
  #-----------------------------------------------------------------------------
  # Extension hook execution
 
  def exec(method, options = {})
    results = nil
    
    if Nucleon.log_level == :hook # To save processing on rendering
      logger.hook("Executing extension hook { #{method} } at #{Time.now} with:\n#{PP.pp(options, '')}\n")
    end
    
    extensions = plugins(:extension)
    
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
          config.defaults(result)
        end
        nil
      else
        hash(data)
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
    
    logger.debug("Extension #{method} collected values: #{values.inspect}")  
    values
  end
       
  #-----------------------------------------------------------------------------
  # Utilities
  
  def translate_type(type, options)
    klass = plugin_class(type)
    logger.debug("Executing option translation for: #{klass.inspect}")          
    
    options = klass.send(:translate, options) if klass.respond_to?(:translate)
    options
  end
  
  #---
  
  def translate(namespace, type, provider, options)
    klass = provider_class(namespace, type, provider)
    logger.debug("Executing option translation for: #{klass.inspect}")
              
    options = klass.send(:translate, options) if klass.respond_to?(:translate)
    options
  end
  
  #---
  
  def class_name(name, separator = '::', want_array = FALSE)
    components = []
    
    case name
    when String, Symbol
      components = name.to_s.split(separator)
    when Array
      components = name 
    end
    
    components.collect! do |value|
      value    = value.to_s.strip      
      value[0] = value.capitalize[0] if value =~ /^[a-z]/ 
      value
    end
    
    if want_array
      return components
    end    
    components.join(separator)
  end
  
  #---
  
  def class_const(name, separator = '::')
    components = class_name(name, separator, TRUE)
    constant   = Object
    
    components.each do |component|
      constant = constant.const_defined?(component) ? 
                  constant.const_get(component) : 
                  constant.const_missing(component)
    end
    constant
  end
  
  #---
  
  def plugin_class(type)
    class_const([ :nucleon, :plugin, type ]) 
  end
  
  #---
  
  def provider_class(namespace, type, provider)
    class_const([ namespace, type, provider ])  
  end
end
end
