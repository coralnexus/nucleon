
module Nucleon
module Plugin
class Base < Core
  
  def self.register_ids
    [ :plugin_name, :name ]
  end
  
  # All Plugin classes should directly or indirectly extend Base
  
  def initialize(namespace, plugin_type, provider, options)
    @actor = Nucleon.handle(self)
    
    config = Util::Data.clean(Config.ensure(options), false)
    name   = Util::Data.ensure_value(config.delete(:plugin_name), config.delete(:name, provider))
    
    @quiet = config.delete(:quiet, false)
       
    set_meta(config.delete(:meta, Config.new))
    
    # No logging statements above this line!!
    super(config.import({ :logger => "#{namespace}->#{plugin_type}->#{plugin_provider}" }), {}, true, false)
    myself.plugin_name = name
            
    logger.debug("Normalizing #{namespace} #{plugin_type} plugin #{plugin_name}")
    normalize(false)
    
    @initialized = true
  end
  
  #---
  
  def parallel_finalize
    remove_plugin
  end
  
  #---
  
  def method_missing(method, *args, &block)  
    return nil  
  end
  
  #---
  
  def remove_plugin
    # Implement in sub classes if needed for cleanup
  end
  
  #-----------------------------------------------------------------------------
  # Checks
  
  def quiet?
    @quiet
  end
   
  #-----------------------------------------------------------------------------
  # Property accessor / modifiers
  
  def myself
    @actor
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
  
  def plugin_namespace
    return meta.get(:namespace)
  end
  
  #---
  
  def plugin_type
    return meta.get(:type)
  end
  
  #---
  
  def plugin_provider
    return meta.get(:provider)
  end
  
  #---
  
  def plugin_name
    return meta.get(:name)
  end
  
  def plugin_name=plugin_name
    meta.set(:name, string(plugin_name))
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
    
  def normalize(reload)
    # Implement in sub classes
  end
  
  #-----------------------------------------------------------------------------
  # Extensions
  
  def hook_method(hook)
    "#{plugin_type}_#{plugin_provider}_#{hook}"  
  end
  
  #---
  
  def extension(hook, options = {}, &code)
    Nucleon.exec(hook_method(hook), Config.ensure(options).import({ :plugin => myself }), &code)
  end
  
  #---
  
  def extended_config(type, options = {})
    config = Nucleon.config(type, Config.ensure(options).import({ :plugin => myself }))
    config.delete(:plugin)
    config
  end
  
  #---
  
  def extension_check(hook, options = {})
    Nucleon.check(hook_method(hook), Config.ensure(options).import({ :plugin => myself }))
  end
  
  #---
  
  def extension_set(hook, value, options = {})
    Nucleon.value(hook_method(hook), value, Config.ensure(options).import({ :plugin => myself }))
  end
  
  #---
  
  def extension_collect(hook, options = {})
    Nucleon.collect(hook_method(hook), Config.ensure(options).import({ :plugin => myself }))
  end
  
  #-----------------------------------------------------------------------------
  # Input
  
  def ask(message, options = {})
    ui.ask(message, options)
  end
  
  #---
  
  def password(type, options = {})
    ui.password(type, options)
  end
  
  #-----------------------------------------------------------------------------
  # Output
  
  def render_options
    export  
  end
  protected :render_options
  
  #---
  
  def render_message(message, options = {})
    config = Config.ensure(options)
    
    if config.delete(:i18n, true)
      message = I18n.t(message, Util::Data.merge([ Config.ensure(render_options).export, config.export ], true))  
    end
    message  
  end
  protected :render_message
  
  #---
  
  def render(data, options = {})
    config = Config.ensure(options)
    
    if ! quiet? || config[:silent]
      translator  = nil
      translator  = CORL.translator({}, config[:format]) if config[:format]
      data        = translator.generate(data) if translator
      
      ui.dump(data, options) unless data.strip.empty? || config[:silent]
    end
    data
  end
  
  #---
        
  def info(message, options = {})
    config = Config.ensure(options)
    
    unless quiet?
      message = render_message(message, config)
      ui.info(message, config.export)
    end
    message
  end
       
  #---
       
  def warn(message, options = {})
    config = Config.ensure(options)
    
    unless quiet?
      message = render_message(message, config)
      ui.warn(message, config.export)
    end
    message
  end
        
  #---
        
  def error(message, options = {})
    config = Config.ensure(options)
    
    unless quiet?
      message = render_message(message, config)
      ui.error(message, config.export)
    end
    message
  end
        
  #---
        
  def success(message, options = {})
    config = Config.ensure(options)
    
    unless quiet?
      message = render_message(message, config)
      ui.success(message, config.export)
    end
    message
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def self.build_info(namespace, plugin_type, data)  
    plugins = []
        
    if data.is_a?(Hash)
      data = [ data ]
    end
    
    logger.debug("Building plugin list of #{plugin_type}")
    
    if data.is_a?(Array)
      data.each do |info|
        unless Util::Data.empty?(info)
          info = translate(info)
          
          if Util::Data.empty?(info[:provider])
            info[:provider] = Nucleon.type_default(namespace, plugin_type)
          end
          
          plugins << info
        end
      end
    end
    return plugins
  end
  
  #---

  def self.translate(data)
    logger.debug("Translating input data to internal plugin structure")
    return ( data.is_a?(Hash) ? symbol_map(data) : data )
  end
  
  #---
  
  def self.translate_reference(reference, editable = false)
    # ex: provider:::name
    if reference && reference.match(/^\s*([a-zA-Z0-9_-]+)(?::::)?(.*)?\s*$/)
      provider = $1
      name     = $2
      
      logger.debug("Translating plugin reference: #{provider}  #{name}")
      
      info = {
        :provider => provider,
        :name     => name
      }
      
      logger.debug("Plugin reference info: #{info.inspect}")
      return info
    end
    nil
  end
  
  #---
  
  def translate_reference(reference, editable = false)
    myself.class.translate_reference(reference, editable)
  end
  
  #---
  
  def self.init_plugin_collection(*external_block_methods)
    logger.debug("Initializing plugin collection interface at #{Time.now}")
    
    include Parallel
    external_block_exec(*external_block_methods)
    
    include Mixin::Settings
    include Mixin::SubConfig
    
    extend Mixin::Macro::PluginInterface
  end
  
  #---
  
  def safe_exec(return_result = true, &code)
    begin
      result = code.call
      return result if return_result
      return true
      
    rescue => error
      logger.error(error.inspect)
      logger.error(error.message)
      
      error(error.message, { :prefix => false, :i18n => false }) if error.message
    end
    return false
  end
  
  #---
  
  def admin_exec(return_result = true, &block)
    if Nucleon.admin?
      safe_exec(return_result, &block)
    else
      warn("The #{plugin_provider} action must be run as a machine administrator", { :i18n => false })
      myself.status = code.access_denied    
    end
  end
end
end
end
