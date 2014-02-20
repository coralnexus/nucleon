
module Nucleon
module Plugin
class Base < Core
  
  include Mixin::Lookup
     
  #---
  
  # All Plugin classes should directly or indirectly extend Base
  
  def initialize(type, provider, options)
    config = Util::Data.clean(Config.ensure(options))
    name   = Util::Data.ensure_value(config.delete(:plugin_name), config.delete(:name, provider))
    @quiet = config.delete(:quiet, false)
       
    set_meta(config.delete(:meta, Config.new))
    
    # No logging statements aove this line!!
    super(config.import({ :logger => "#{plugin_type}->#{plugin_provider}" }))
    myself.plugin_name = name
    
    logger.debug("Set #{plugin_type} plugin #{plugin_name} meta data: #{meta.inspect}")    
    logger.debug("Normalizing #{plugin_type} plugin #{plugin_name}")
    normalize
  end
  
  #---
  
  def method_missing(method, *args, &block)  
    return nil  
  end
  
  #-----------------------------------------------------------------------------
  # Checks
  
  def initialized?(options = {})
    return true  
  end
  
  #---
  
  def quiet?
    @quiet
  end
   
  #-----------------------------------------------------------------------------
  # Property accessor / modifiers
  
  def myself
    return current_actor if respond_to?(:current_actor) # Celluloid enhanced plugin
    self
  end
  alias_method :me, :myself
  
  #---
  
  def quiet=quiet
    @quiet = quiet
  end
  
  #---
  
  def meta
    return @meta
  end
  
  #---
  
  def set_meta(meta)
    @meta = Config.ensure(meta)
  end
  
  #---
  
  def plugin_name
    return meta.get(:name)
  end
  alias_method :name, :plugin_name
  
  def plugin_name=plugin_name
    meta.set(:name, string(plugin_name))
  end
  alias_method :name=, :plugin_name=
  
  #---
  
  def plugin_type
    return meta.get(:type)
  end
  
  #---
  
  def plugin_provider
    return meta.get(:provider)
  end
  
  #---
  
  def plugin_directory
    return meta.get(:directory)
  end
  
  #---
  
  def plugin_file
    return meta.get(:file)
  end
  
  #---
  
  def plugin_instance_name
    return meta.get(:instance_name)
  end
  
  #---
  
  def plugin_parent=parent
    meta.set(:parent, parent) if parent.is_a?(Nucleon::Plugin::Base)
  end
  
  def plugin_parent
    return meta.get(:parent)
  end

  #-----------------------------------------------------------------------------
  # Status codes
    
  def code
    Nucleon.code
  end
  
  def codes(*codes)
    Nucleon.codes(*codes)
  end

  #---
  
  def status=status
    meta.set(:status, status)
  end
  
  def status
    meta.get(:status, code.unknown_status)
  end

  #-----------------------------------------------------------------------------
  # Plugin operations
    
  def normalize
  end
  
  #-----------------------------------------------------------------------------
  # Extensions
  
  def hook_method(hook)
    "#{plugin_type}_#{plugin_provider}_#{hook}"  
  end
  
  #---
  
  def extension(hook, options = {})
    method = hook_method(hook)
    
    logger.debug("Executing plugin hook #{hook} (#{method})")
    
    return Manager.connection.exec(method, Config.ensure(options).defaults({ :extension_type => :base }).import({ :plugin => myself })) do |op, results|
      results = yield(op, results) if block_given?
      results
    end
  end
  
  #---
  
  def extended_config(type, options = {})
    config = Config.ensure(options)
    
    logger.debug("Generating #{type} extended configuration from: #{config.export.inspect}")
      
    extension("#{type}_config", Config.new(config.export).import({ :extension_type => :config })) do |op, results|
      if op == :reduce
        results.each do |provider, result|
          config.defaults(result)
        end
        nil
      else
        hash(results)
      end
    end    
    config.delete(:extension_type)
     
    logger.debug("Final extended configuration: #{config.export.inspect}")   
    config 
  end
  
  #---
  
  def extension_check(hook, options = {})
    config = Config.ensure(options)
    
    logger.debug("Checking extension #{plugin_provider} #{hook} given: #{config.export.inspect}")
    
    success = extension(hook, config.import({ :extension_type => :check })) do |op, results|
      if op == :reduce
        ! results.values.include?(false)
      else
        results ? true : false
      end
    end
    
    success = success.nil? || success ? true : false
    
    logger.debug("Extension #{plugin_provider} #{hook} check result: #{success.inspect}")  
    success
  end
  
  #---
  
  def extension_set(hook, value, options = {})
    config = Config.ensure(options)
    
    logger.debug("Setting extension #{plugin_provider} #{hook} value given: #{value.inspect}")
    
    extension(hook, config.import({ :value => value, :extension_type => :set })) do |op, results|
      if op == :process
        value = results unless results.nil?  
      end
    end
    
    logger.debug("Extension #{plugin_provider} #{hook} set value to: #{value.inspect}")  
    value
  end
  
  #---
  
  def extension_collect(hook, options = {})
    config = Config.ensure(options)
    values = []
    
    logger.debug("Collecting extension #{plugin_provider} #{hook} values")
    
    extension(hook, config.import({ :extension_type => :add })) do |op, results|
      if op == :process
        values << results unless results.nil?  
      end
    end
    
    logger.debug("Extension #{plugin_provider} #{hook} collected values: #{values.inspect}")  
    values
  end
  
  #-----------------------------------------------------------------------------
  # Output
  
  def render_options
    export  
  end
  protected :render_options
  
  #---
  
  def render(display, options = {})
    ui.info(display.strip, options) unless quiet? || display.strip.empty?
  end
  
  #---
        
  def info(name, options = {})
    ui.info(I18n.t(name, Util::Data.merge([ Config.ensure(render_options).export, options ], true))) unless quiet?
  end
  
  #---
   
  def alert(display, options = {})
    ui.warn(display.strip, options) unless quiet? || display.strip.empty?
  end
        
  #---
       
  def warn(name, options = {})
    ui.warn(I18n.t(name, Util::Data.merge([ Config.ensure(render_options).export, options ], true))) unless quiet?  
  end
        
  #---
        
  def error(name, options = {})
    ui.error(I18n.t(name, Util::Data.merge([ Config.ensure(render_options).export, options ], true))) unless quiet?  
  end
        
  #---
        
  def success(name, options = {})
    ui.success(I18n.t(name, Util::Data.merge([ Config.ensure(render_options).export, options ], true))) unless quiet?  
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def self.build_info(type, data)  
    plugins = []
        
    if data.is_a?(Hash)
      data = [ data ]
    end
    
    logger.debug("Building plugin list of #{type} from data: #{data.inspect}")
    
    if data.is_a?(Array)
      data.each do |info|
        unless Util::Data.empty?(info)
          info = translate(info)
          
          if Util::Data.empty?(info[:provider])
            info[:provider] = Manager.connection.type_default(type)
          end
          
          logger.debug("Translated plugin info: #{info.inspect}")
          
          plugins << info
        end
      end
    end
    return plugins
  end
  
  #---

  def self.translate(data)
    logger.debug("Translating data to internal plugin structure: #{data.inspect}")
    return ( data.is_a?(Hash) ? symbol_map(data) : {} )
  end
  
  #---
  
  def self.init_plugin_collection
    logger.debug("Initializing plugin collection interface at #{Time.now}")
    
    include Celluloid
    include Mixin::Settings
    include Mixin::SubConfig
    
    extend Mixin::Macro::PluginInterface
  end
  
  #---
  
  def safe_exec(return_result = true)
    begin
      result = yield
      return result if return_result
      return true
      
    rescue Exception => e
      logger.error(e.inspect)
      logger.error(e.message)
      
      ui.error(e.message, { :prefix => false }) if e.message
    end
    return false
  end
  
  #---
  
  def admin_exec
    if Nucleon.admin?
      yield if block_given?
    else
      ui.warn("The #{plugin_provider} action must be run as a machine administrator")
      myself.status = code.access_denied    
    end
  end
end
end
end
