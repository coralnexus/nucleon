
module Nucleon
 
  VERSION = File.read(File.join(File.dirname(__FILE__), '..', '..', 'VERSION'))
  
  #-----------------------------------------------------------------------------
  
  def self.ui
    Core.ui
  end
  
  def self.quiet=quiet
    Util::Console.quiet = quiet  
  end
  
  #---
  
  def self.logger
    Core.logger
  end
  
  def self.log_level
    Util::Logger.level
  end
  
  def self.log_level=log_level
    Util::Logger.level = log_level
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
  # Core plugin interface
  
  def self.reload
    Manager.connection.reload  
  end
  
  #---
  
  def self.types
    Manager.connection.types
  end
  
  def self.define_type(type_info)
    Manager.connection.define_type(type_info)
  end
   
  def self.type_default(type)
    Manager.connection.type_default(type)
  end
  
  #---
  
  def self.register(path)
    Manager.connection.register(path)
    Manager.connection.autoload
  end
  
  def self.loaded_plugins(type = nil, provider = nil)
    Manager.connection.loaded_plugins(type, provider)    
  end
  
  #---
  
  def self.active_plugins(type = nil, provider = nil)
    Manager.connection.plugins(type, provider)    
  end
  
  #---
  
  def self.plugin(type, provider, options = {})
    default_provider = type_default(type)
    
    if options.is_a?(Hash) || options.is_a?(Nucleon::Config)
      config   = Config.ensure(options)
      provider = config.get(:provider, provider)
      options  = config.export
    end
    provider = default_provider unless provider # Sanity checking (see plugins)
    
    Manager.connection.load(type, provider, options)
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
  # Core plugin type facade
  
  def self.extension(provider)
    plugin(:extension, provider, {})
  end
  
  #---
  
  def self.action(provider, options)
    plugin(:action, provider, options)
  end
  
  def self.actions(data, build_hash = false, keep_array = false)
    plugins(:action, data, build_hash, keep_array)  
  end
  
  def self.action_config(provider)
    action(provider, { :settings => {}, :quiet => true }).configure
  end
  
  def self.action_run(provider, options = {}, quiet = true)
    Plugin::Action.exec(provider, options, quiet)
  end
  
  def self.action_cli(provider, args = [], quiet = false)
    Plugin::Action.exec_cli(provider, args, quiet)
  end
  
  #---
  
  def self.project(options, provider = nil)
    plugin(:project, provider, options)
  end
  
  def self.projects(data, build_hash = false, keep_array = false)
    plugins(:project, data, build_hash, keep_array)
  end
   
  #-----------------------------------------------------------------------------
  # Utility plugin type facade
  
  def self.command(options, provider = nil)
    plugin(:command, provider, options)
  end
  
  def self.commands(data, build_hash = false, keep_array = false)
    plugins(:command, data, build_hash, keep_array)
  end
   
  #---
  
  def self.event(options, provider = nil)
    plugin(:event, provider, options)
  end
  
  def self.events(data, build_hash = false, keep_array = false)
    plugins(:event, data, build_hash, keep_array)
  end
  
  #---
  
  def self.template(options, provider = nil)
    plugin(:template, provider, options)
  end
  
  def self.templates(data, build_hash = false, keep_array = false)
    plugins(:template, data, build_hash, keep_array)
  end
   
  #---
  
  def self.translator(options, provider = nil)
    plugin(:translator, provider, options)
  end
  
  def self.translators(data, build_hash = false, keep_array = false)
    plugins(:translator, data, build_hash, keep_array)
  end
  
  #-----------------------------------------------------------------------------
  # Plugin extensions
   
  def self.exec(method, options = {}, &code)
    Manager.connection.exec(method, options, &code)
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
  
  #---
  
  def self.collect(method, options = {})
    Manager.connection.collect(method, options)
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
  
  #---
    
  def self.cli_run(command, options = {}, &code)
    command = command.join(' ') if command.is_a?(Array)
    config  = Config.ensure(options)
    
    logger.info("Executing command #{command}")
        
    result = Util::Shell.connection.exec(command, config, &code)
    
    unless result.status == Nucleon.code.success
      ui.error("Command #{command} failed to execute")
    end     
    result
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def self.class_name(name, separator = '::', want_array = false)
    Manager.connection.class_name(name, separator, want_array)
  end
  
  #---
  
  def self.class_const(name, separator = '::')
    Manager.connection.class_const(name, separator)
  end
  
  #---
  
  def self.sha1(data)
    Digest::SHA1.hexdigest(Util::Data.to_json(data, false))
  end  
end
