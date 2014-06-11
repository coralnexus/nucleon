
module Nucleon
class Environment
  
  #-----------------------------------------------------------------------------
  # Constructor / Destructor
  
  def initialize
    @plugin_types = {}
    
    @load_info    = {}    
    @active_info  = {}
  end
  
  #-----------------------------------------------------------------------------
  # Plugin type accessor / modifiers
  
  def namespaces
    @plugin_types.keys
  end
  
  #---
  
  def plugin_types(namespace)
    namespace = namespace.to_sym
    
    return [] unless @plugin_types.has_key?(namespace)
    @plugin_types[namespace].keys
  end
  
  #---
  
  def define_plugin_type(namespace, plugin_type, default_provider = nil)
    namespace = namespace.to_sym
    
    @plugin_types[namespace] = {} unless @plugin_types.has_key?(namespace)
    @plugin_types[namespace][sanitize_id(plugin_type)] = default_provider
  end
  
  #---
  
  def define_plugin_types(namespace, type_info)
    if type_info.is_a?(Hash)
      type_info.each do |plugin_type, default_provider|
        define_plugin_type(namespace, plugin_type, default_provider)
      end
    end
  end
  
  #---
  
  def plugin_type_defined?(namespace, plugin_type)
    namespace = namespace.to_sym
    
    return false unless @plugin_types.has_key?(namespace)
    @plugin_types[namespace].has_key?(sanitize_id(plugin_type))
  end
  
  #---
  
  def plugin_type_default(namespace, plugin_type)
    namespace = namespace.to_sym
    
    return nil unless @plugin_types.has_key?(namespace)
    @plugin_types[namespace][sanitize_id(plugin_type)]
  end
  
  #-----------------------------------------------------------------------------
  # Loaded plugin accessor / modifiers
  
  def define_plugin(namespace, plugin_type, base_path, file, &code)
    namespace   = namespace.to_sym
    plugin_type = sanitize_id(plugin_type)
    
    @load_info[namespace]              = {} unless @load_info.has_key?(namespace)
    @load_info[namespace][plugin_type] = {} unless @load_info[namespace].has_key?(plugin_type)
    
    plugin_info = parse_plugin_info(namespace, plugin_type, base_path, file)
    
    unless @load_info[namespace][plugin_type].has_key?(plugin_info[:provider])
      data = {
        :namespace        => namespace,
        :type             => plugin_type,
        :file             => file,
        :provider         => plugin_info[:provider],        
        :directory        => plugin_info[:directory],        
        :class_components => plugin_info[:class_components]
      }
      code.call(data) if code
      
      @load_info[namespace][plugin_type][plugin_info[:provider]] = data
    end
  end
  
  #---
  
  def loaded_plugin(namespace, plugin_type, provider)
    namespace   = namespace.to_sym
    plugin_type = sanitize_id(plugin_type)
    provider    = sanitize_id(provider)
    info        = nil
    
    if @load_info.has_key?(namespace) && 
      @load_info[namespace].has_key?(plugin_type) && 
      @load_info[namespace][plugin_type].has_key?(provider) 
      
      info = @load_info[namespace][plugin_type][provider]
    end
    info
  end
  
  #---
  
  def loaded_plugins(namespace = nil, plugin_type = nil, provider = nil, default = {})
    namespace   = namespace.to_sym if namespace
    plugin_type = sanitize_id(plugin_type) if plugin_type
    provider    = sanitize_id(provider) if provider
    results     = default
    
    if namespace && @load_info.has_key?(namespace)
      if plugin_type && @load_info[namespace].has_key?(plugin_type)
        if provider && @load_info[namespace][plugin_type].has_key?(provider)
          results = @load_info[namespace][plugin_type][provider]  
        elsif ! provider
          results = @load_info[namespace][plugin_type]
        end
      elsif ! plugin_type
        results = @load_info[namespace]      
      end
    elsif ! namespace
      results = @load_info
    end
    results
  end
  
  #---
  
  def plugin_has_type?(namespace, plugin_type)
    namespace = namespace.to_sym
    
    return false unless @load_info.has_key?(namespace)
    @load_info[namespace].has_key?(sanitize_id(plugin_type))
  end
  
  #---
  
  def plugin_has_provider?(namespace, plugin_type, provider)
    namespace   = namespace.to_sym
    plugin_type = sanitize_id(plugin_type)
    provider    = sanitize_id(provider)
    
    return false unless @load_info.has_key?(namespace) && @load_info[namespace].has_key?(plugin_type)
    @load_info[namespace][plugin_type].has_key?(provider)
  end
  
  #-----------------------------------------------------------------------------
  # Active plugin accessor / modifiers
  
  def create_plugin(namespace, plugin_type, provider, options = {}, &code)
    namespace   = namespace.to_sym
    plugin_type = sanitize_id(plugin_type)
    provider    = sanitize_id(provider)
       
    unless plugin_type_defined?(namespace, plugin_type)
      return nil
    end
        
    if type_info = loaded_plugin(namespace, plugin_type, provider)
      instance_name = "#{provider}_" + Nucleon.sha1(options)            
      
      @active_info[namespace] = {} unless @active_info.has_key?(namespace)        
      @active_info[namespace][plugin_type] = {} unless @active_info[namespace].has_key?(plugin_type)
      
      unless instance_name && @active_info[namespace][plugin_type].has_key?(instance_name)
        type_info[:instance_name] = instance_name
        
        options = code.call(type_info, options) if code
        plugin  = type_info[:class].new(namespace, plugin_type, provider, options)
        
        @active_info[namespace][plugin_type][instance_name] = plugin 
      end
      return @active_info[namespace][plugin_type][instance_name]
    end  
    nil  
  end
  
  #---
  
  def get_plugin(namespace, plugin_type, plugin_name)
    namespace   = namespace.to_sym
    plugin_type = sanitize_id(plugin_type)
    
    if @active_info.has_key?(namespace) && @active_info[namespace].has_key?(plugin_type)
      @active_info[namespace][plugin_type].each do |instance_name, plugin|
        if plugin.plugin_name.to_s == plugin_name.to_s
          return plugin
        end
      end
    end
    nil  
  end
  
  #---
  
  def remove_plugin(namespace, plugin_type, instance_name, &code)
    namespace   = namespace.to_sym
    plugin_type = sanitize_id(plugin_type)
    
    if @active_info.has_key?(namespace) && @active_info[namespace].has_key?(plugin_type)
      code.call if code
      @active_info[namespace][plugin_type].delete(instance_name)
    end
  end
  
  #---
  
  def active_plugins(namespace = nil, plugin_type = nil, provider = nil)
    namespace   = namespace.to_sym if namespace
    plugin_type = sanitize_id(plugin_type) if plugin_type
    provider    = sanitize_id(provider) if provider
    results     = {}
    
    if namespace && @active_info.has_key?(namespace)
      if plugin_type && @active_info[namespace].has_key?(plugin_type)
        if provider && ! @active_info[namespace][plugin_type].keys.empty?
          @active_info[namespace][plugin_type].each do |instance_name, plugin|
            plugin                 = @active_info[namespace][plugin_type][instance_name]
            results[instance_name] = plugin if plugin.plugin_provider == provider
          end
        elsif ! provider
          results = @active_info[namespace][plugin_type]
        end
      elsif ! plugin_type
        results = @active_info[namespace]
      end
    elsif ! namespace
      results = @active_info  
    end    
    results
  end 
  
  #-----------------------------------------------------------------------------
  # Utilities
  
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
  
  def sanitize_id(id_component)
    id_component.to_s.gsub(/([a-z0-9])(?:\-|\_)?([A-Z])/, '\1_\2').downcase.to_sym
  end
  protected :sanitize_id
  
  #---
  
  def sanitize_class(class_component)
    class_component.to_s.split('_').collect {|elem| elem.slice(0,1).capitalize + elem.slice(1..-1) }.join('')  
  end
  protected :sanitize_class
  
  #---
  
  def plugin_class(namespace, plugin_type)
    class_const([ sanitize_class(namespace), :plugin, sanitize_class(plugin_type) ]) 
  end
  
  #---
  
  def parse_plugin_info(namespace, plugin_type, base_path, file)
    dir_components   = base_path.split(File::SEPARATOR)    
    file_components  = file.split(File::SEPARATOR)  
    
    file_name        = file_components.pop.sub(/\.rb/, '')
    directory        = file_components.join(File::SEPARATOR)
    
    file_class       = sanitize_class(file_name)
    group_components = file_components - dir_components
    
    class_components = [ sanitize_class(namespace), sanitize_class(plugin_type) ]
      
    if ! group_components.empty? 
      group_name       = group_components.collect {|elem| elem.downcase  }.join('_')
      provider         = [ group_name, file_name ].join('_')
      
      group_components = group_components.collect {|elem| sanitize_class(elem) }
      class_components = [ class_components, group_components, file_class ].flatten
    else
      provider         = file_name
      class_components = [ class_components, file_class ].flatten
    end
    
    { 
      :directory        => directory, 
      :provider         => sanitize_id(provider), 
      :class_components => class_components
    }    
  end
  protected :parse_plugin_info
end
end
