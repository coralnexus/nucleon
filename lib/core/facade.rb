
module Nucleon
 
  VERSION = File.read(File.join(File.dirname(__FILE__), '..', '..', 'VERSION'))
  
  #-----------------------------------------------------------------------------
  
  def self.ui
    Core.ui
  end
  
  #---
  
  def self.logger
    Core.logger
  end
  
  #---
  
  def self.add_log_levels(*levels)
    Util::Interface.add_log_levels(levels)  
  end
  
  def self.log_level
    Util::Interface.log_level
  end
  
  def self.log_level=log_level
    Util::Interface.log_level = log_level
  end
  
  #-----------------------------------------------------------------------------
  
  def self.admin?
    is_admin  = ( ENV['USER'] == 'root' )
    ext_admin = exec(:check_admin) do |op, results|
      if op == :reduce
        results.values.include?(true)
      else
        results ? true : false
      end
    end
    is_admin || ext_admin ? true : false
  end
  
  #-----------------------------------------------------------------------------
  # Status codes
  
  @@codes = Codes.new
  
  def self.code
    @@codes
  end
  
  def self.codes(*codes)
    Codes.codes(*codes)
  end

  #-----------------------------------------------------------------------------
  # Initialization
  
  def self.initialize
    current_time = Time.now
    
    Celluloid.logger = logger
      
    logger.info("Initializing the Nucleon plugin system at #{current_time}")
    Config.set_property('time', current_time.to_i)
    
    connection = Manager.connection
      
    connection.define_type :extension     => nil,         # Core
                           :action        => :update,     # Core
                           :project       => :git,        # Core
                           :command       => :shell,      # Core
                           :event         => :regex,      # Utility
                           :template      => :json,       # Utility
                           :translator    => :json        # Utility
                           
    connection.load_plugins(true)
                                  
    logger.info("Finished initializing Nucleon plugin system at #{Time.now}")    
  end
  
  #-----------------------------------------------------------------------------
  # Core plugin interface
  
  def self.plugin_load(type, provider, options = {})
    config = Config.ensure(options)
    name   = config.get(:name, nil)
    
    logger.info("Fetching plugin #{type} provider #{provider} at #{Time.now}")
    logger.debug("Plugin options: #{config.export.inspect}")
    
    connection = Manager.connection
    
    if name
      logger.debug("Looking up existing instance of #{name}")
      
      existing_instance = connection.get(type, name)
      logger.info("Using existing instance of #{type}, #{name}") if existing_instance
    end
    
    return existing_instance if existing_instance
    connection.create(type, provider, config.export)  
  end
  
  #---
  
  def self.plugin(type, provider, options = {})
    default_provider = Manager.connection.type_default(type)
    
    if options.is_a?(Hash) || options.is_a?(Nucleon::Config)
      config   = Config.ensure(options)
      provider = config.get(:provider, provider)
      options  = config.export
    end
    provider = default_provider unless provider # Sanity checking (see plugins)
    
    plugin_load(type, provider, options)
  end
  
  #---
  
  def self.plugins(type, data, build_hash = false, keep_array = false)
    logger.info("Fetching multiple plugins of #{type} at #{Time.now}")
    
    group = ( build_hash ? {} : [] )
    klass = class_const([ :nucleon, :plugin, type ])    
    data  = klass.build_info(type, data) if klass.respond_to?(:build_info)
    
    logger.debug("Translated plugin data: #{data.inspect}")
    
    data.each do |options|
      if plugin = plugin(type, options[:provider], options)
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
  
  def self.get_plugin(type, name)
    Manager.connection.get(type, name)
  end
  
  #---
  
  def self.remove_plugin(plugin)
    Manager.connection.remove(plugin)
  end

  #-----------------------------------------------------------------------------
  # Plugin extensions
   
  def self.exec(method, options = {})
    Manager.connection.exec(method, options) do |op, data|
      data = yield(op, data) if block_given?
      data
    end
  end
  
  #---
  
  def self.config(type, options = {})
    Manager.connection.config(method, options)
  end
  
  #---
  
  def self.check(method, options = {})
    Manager.connection.check(method, options)
  end
  
  #---
  
  def self.value(method, value, options = {})
    Manager.connection.value(method, value, options)
  end
       
  #-----------------------------------------------------------------------------
  # External execution
   
  def self.run
    begin
      logger.debug("Running contained process at #{Time.now}")
      yield
      
    rescue Exception => error
      logger.error("Nucleon run experienced an error! Details:")
      logger.error(error.inspect)
      logger.error(error.message)
      logger.error(Util::Data.to_yaml(error.backtrace))
  
      ui.error(error.message) if error.message
      raise
    end
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def self.class_name(name, separator = '::', want_array = FALSE)
    components = []
    
    case name
    when String, Symbol
      components = name.to_s.split(separator)
    when Array
      components = name 
    end
    
    components.collect! do |value|
      value.to_s.strip.capitalize  
    end
    
    if want_array
      return components
    end    
    components.join(separator)
  end
  
  #---
  
  def self.class_const(name, separator = '::')
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
  
  def self.sha1(data)
    Digest::SHA1.hexdigest(Util::Data.to_json(data, false))
  end  
end
