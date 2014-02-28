
# Should be included via extend
#
# extend Mixin::Macro::PluginInterface
#

nucleon_require(File.dirname(__FILE__), :object_interface)

#---

module Nucleon
module Mixin
module Macro
module PluginInterface
  
  include Macro::ObjectInterface
  
  #-----------------------------------------------------------------------------
  # Plugin collections
  
  def plugin_collection(_type, _method_options = {})
    _method_config = Config.ensure(_method_options)
    _method_config.set(:plugin, true)
    
    _plural          = _method_config.init(:plural, "#{_type}s").get(:plural)
    _search_proc     = _method_config.get(:search_proc)
    _single_instance = _method_config.get(:single_instance, false)
    _plugin_type     = _method_config.get(:plugin_type, _type)
    
    @@object_types[_type] = _method_config
    
    logger.debug("Creating new plugin collection #{_type} with: #{_method_config.inspect}")
    
    #---------------------------------------------------------------------------
    
    object_utilities
      
    #---
    
    unless respond_to? :each_plugin
      logger.debug("Defining plugin interface method: each_plugin")
      
      define_method :each_plugin do |plugin_types = nil, providers = nil, &code|
        providers = [ providers ] if providers && ! providers.is_a?(Array)
        
        filter_proc = Proc.new {|type, config| config[:plugin] }
        each_object_type(plugin_types, filter_proc) do |type, plural, options|
          logger.debug("Processing plugin type #{type}/#{plural} with: #{options.inspect}")
          
          send(plural).each do |provider, plugins|
            logger.debug("Processing plugin provider: #{provider}")
            
            unless providers && ! providers.include?(provider)
              if plugins.is_a?(Hash)
                plugins.each do |name, plugin|
                  logger.debug("Processing plugin: #{name}")
                  code.call(type, provider, name, plugin)  
                end
              else
                logger.debug("Processing plugin: #{plugin.name}")
                code.call(type, provider, plugin.name, plugin)
              end
            end
          end 
        end  
      end
    end
    
    #---
    
    logger.debug("Defining plugin interface method: each_#{_type}")
    
    define_method "each_#{_type}" do |providers = nil, &code|
      each_plugin(_type, providers) do |type, provider, name, plugin|
        code.call(provider, name, plugin)    
      end
    end
    
    #---------------------------------------------------------------------------
    
    logger.debug("Defining plugin interface method: #{_plural}")
    
    define_method "#{_plural}" do |provider = nil, reset = false|
      keys = ( provider ? [ _plural, provider ] : _plural )
      send("init_#{_plural}", provider) if reset || _get(keys, {}).empty?
      _get(keys, {})
    end
    
    #---
    
    logger.debug("Defining plugin interface method: init_#{_plural}")
  
    define_method "init_#{_plural}" do |providers = nil|
      data = hash(_search_proc.call) if _search_proc
      data = get_hash(_plural) unless data
      
      providers = [ providers ] if providers && ! providers.is_a?(Array)
      
      logger.debug("Initializing #{_plugin_type} plugin data: #{data.inspect}")
      logger.debug("Providers: #{providers.inspect}")
            
      symbol_map(data).each do |provider, instance_settings|
        if ! providers || providers.include?(provider)
          if _single_instance
            logger.debug("Initializing single instance plugin: #{instance_settings.inspect}")
            
            plugin = Nucleon.plugin(_plugin_type, provider, Config.ensure(instance_settings).import({ :meta => { :parent => myself } }))
          
            _set([ _plural, provider ], plugin)
          else
            instance_settings.each do |name, options|
              if name != :settings
                logger.debug("Initializing plugin #{_plugin_type} #{name}: #{options.inspect}")
                
                plugin = Nucleon.plugin(_plugin_type, provider, Config.ensure(options).import({ :name => name, :meta => { :parent => myself } }))
                
                _set([ _plural, provider, name ], plugin)
              end
            end
          end
        end
      end
    end
  
    #---
    
    logger.debug("Defining plugin interface method: set_#{_plural}")

    define_method "set_#{_plural}" do |data = {}|
      data = Config.ensure(data).export
    
      send("clear_#{_plural}")
      set(_plural, data)
      
      logger.debug("Setting #{_plural}")
    
      data.each do |provider, instance_settings|
        if _single_instance
          logger.debug("Setting single #{_plugin_type} #{provider}: #{instance_settings.inspect}")
          
          plugin = Nucleon.plugin(_plugin_type, provider, Config.ensure(instance_settings).import({ :meta => { :parent => myself } }))              
          
          _set([ _plural, provider ], plugin)  
        else
          instance_settings.each do |name, options|
            logger.debug("Setting #{_plugin_type} #{provider} #{name}: #{options.inspect}")
            
            plugin = Nucleon.plugin(_plugin_type, provider, Config.ensure(options).import({ :name => name, :meta => { :parent => myself } }))
            
            _set([ _plural, provider, name ], plugin)  
          end
        end
      end
    end
    
    #---
    
    logger.debug("Defining plugin interface method: clear_#{_plural}")
    
    define_method "clear_#{_plural}" do
      get(_plural).keys.each do |provider|
        logger.debug("Clearing #{_type} #{provider}")
        
        if _single_instance
          send("delete_#{_type}", provider)
        else
          get_hash([ _plural, provider ]).keys.each do |name|
            send("delete_#{_type}", provider, name)
          end
        end
      end
    end

    #---------------------------------------------------------------------------
    
    if _single_instance
      logger.debug("Defining single instance plugin interface method: #{_type}_config")
      
      define_method "#{_type}_config" do |provider = nil|
        keys = [ _plural ]
        keys << provider unless provider.nil?
        Config.new(get(keys, {}))
      end
      
      #---
      
      logger.debug("Defining single instance plugin interface method: #{_type}_setting")
      
      define_method "#{_type}_setting" do |provider, property, default = nil, format = false|
        get([ _plural, provider, property ], default, format)
      end
      
      #---
      
      logger.debug("Defining single instance plugin interface method: #{_type}")
      
      define_method "#{_type}" do |provider, reset = false|
        if reset || _get([ _plural, provider ], nil).nil?        
          options = get([ _plural, provider ], nil)
         
          unless options.nil?
            plugin = Nucleon.plugin(_plugin_type, provider, Config.ensure(options).import({ :meta => { :parent => myself } }))
        
            logger.debug("Initializing plugin #{_plugin_type} #{provider}: #{options.inspect}")
        
            _set([ _plural, provider ], plugin)
          end
        end
        _get([ _plural, provider ])
      end
      
      #---
      
      logger.debug("Defining single instance plugin interface method: set_#{_type}")
      
      define_method "set_#{_type}" do |provider, options = {}|
        options = Config.ensure(options).export
      
        set([ _plural, provider ], options)
    
        plugin = Nucleon.plugin(_plugin_type, provider, Config.ensure(options).import({ :meta => { :parent => myself } }))
        
        logger.debug("Setting single #{_plugin_type} #{provider}: #{options.inspect}")
        
        _set([ _plural, provider ], plugin)
        plugin
      end
          
      #---
      
      logger.debug("Defining single instance plugin interface method: set_#{_type}_setting")

      define_method "set_#{_type}_setting" do |provider, property, value = nil|
        logger.debug("Setting single #{provider} property #{property} to #{value.inspect}")
        set([ _plural, provider, property ], value)
      end
    
      #---
      
      logger.debug("Defining single instance plugin interface method: delete_#{_type}")

      define_method "delete_#{_type}" do |provider, remove_plugin = true|
        plugin = send(_type, provider)
        
        logger.debug("Deleting single #{_type} #{provider}")
    
        delete([ _plural, provider ])
        _delete([ _plural, provider ])
    
        Nucleon.remove_plugin(plugin) if remove_plugin && ! plugin.nil?
      end
  
      #---
      
      logger.debug("Defining single instance plugin interface method: delete_#{_type}_setting")
  
      define_method "delete_#{_type}_setting" do |provider, property|
        logger.debug("Deleting single #{provider} property: #{property}")
        delete([ _plural, provider, property ])
      end
      
      #---
      
      logger.debug("Defining single instance plugin interface method: search_#{_type}")
      
      define_method "search_#{_type}" do |provider, keys, default = '', format = false|
        plugin_config = send("#{_type}_config", provider)
        logger.debug("Searching single #{_type} #{provider}: #{plugin_config.inspect}")
        
        search_object(plugin_config, keys, default, format)      
      end
      
    #---------------------------------------------------------------------------
    else
      logger.debug("Defining multi instance plugin interface method: #{_type}_config")
      
      define_method "#{_type}_config" do |provider = nil, name = nil|
        keys = [ _plural ]
        keys << provider unless provider.nil?
        keys << name unless name.nil?
        Config.new(get(keys, {}))
      end
      
      #---
      
      logger.debug("Defining multi instance plugin interface method: #{_type}_setting")
      
      define_method "#{_type}_setting" do |provider, name, property, default = nil, format = false|
        get([ _plural, provider, name, property ], default, format)
      end
      
      #---
      
      logger.debug("Defining multi instance plugin interface method: #{_type}")
      
      define_method "#{_type}" do |provider, name|
        if reset || _get([ _plural, provider, name ], nil).nil?        
          options = get([ _plural, provider, name ], nil)
         
          unless options.nil?
            plugin = Nucleon.plugin(_plugin_type, provider, Config.ensure(options).import({ :name => name, :meta => { :parent => myself } }))
        
            logger.debug("Initializing plugin #{_plugin_type} #{provider}: #{options.inspect}")
        
            _set([ _plural, provider, name ], plugin)
          end
        end
        _get([ _plural, provider, name ])
      end
      
      #---
      
      logger.debug("Defining multi instance plugin interface method: set_#{_type}")
      
      define_method "set_#{_type}" do |provider, name, options = {}|
        options = Config.ensure(options).export
      
        set([ _plural, provider, name ], options)
        plugin = Nucleon.plugin(_plugin_type, provider, Config.ensure(options).import({ :name => name, :meta => { :parent => myself } }))
        
        logger.debug("Setting #{_plugin_type} #{provider} #{name}: #{options.inspect}")
        
        _set([ _plural, provider, name ], plugin)
        plugin
      end
          
      #---
      
      logger.debug("Defining multi instance plugin interface method: set_#{_type}_setting")

      define_method "set_#{_type}_setting" do |provider, name, property, value = nil|
        logger.debug("Setting #{provider} #{name} property #{property} to #{value.inspect}")
        set([ _plural, provider, name, property ], value)
      end
    
      #---
      
      logger.debug("Defining multi instance plugin interface method: delete_#{_type}")

      define_method "delete_#{_type}" do |provider, name, remove_plugin = true|
        plugin = send(_type, provider, name)
        
        logger.debug("Deleting #{_type} #{provider} #{name}")
    
        delete([ _plural, provider, name ])
        _delete([ _plural, provider, name ])
    
        Nucleon.remove_plugin(plugin) if remove_plugin && ! plugin.nil?
      end
  
      #---
      
      logger.debug("Defining multi instance plugin interface method: delete_#{_type}_setting")
  
      define_method "delete_#{_type}_setting" do |provider, name, property|
        logger.debug("Deleting #{provider} #{name} property: #{property}")
        delete([ _plural, provider, name, property ])
      end
      
      #---
      
      logger.debug("Defining multi instance plugin interface method: search_#{_type}")
      
      define_method "search_#{_type}" do |provider, name, keys, default = '', format = false|
        plugin_config = send("#{_type}_config", provider, name)
        logger.debug("Searching #{_type} #{provider} #{name}: #{plugin_config.inspect}")
        
        search_object(plugin_config, keys, default, format)      
      end
    end  
  end
end
end
end
end
