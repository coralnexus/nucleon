
module Nucleon
module Mixin
module Action
module Registration
        
  #-----------------------------------------------------------------------------
  # Registration definitions
  
  def register_bool(name, default = false, locale = nil, &code)
    register(name, :bool, default, locale, &code)
  end
  
  #---
  
  def register_int(name, default = nil, locale = nil, &code)
    register(name, :int, default, locale, &code)
  end
  
  #---
  
  def register_float(name, default = nil, locale = nil, &code)
    register(name, :float, default, locale, &code)
  end
  
  #---
  
  def register_str(name, default = '', locale = nil, &code)
    register(name, :str, default, locale, &code)
  end
  
  #---
  
  def register_array(name, default = [], locale = nil, &code)
    register(name, :array, default, locale, &code)
  end
  
  #---
    
  def register_file(name, default = nil, locale = nil, &code)
    name = name.to_sym
    
    register_str(name, default, locale) do |value|
      success = validate_file(value)
      success = code.call(value, success) if code
      success
    end
  end
  
  #---
  
  def register_files(name, default = nil, locale = nil, &code)
    name = name.to_sym
    
    option_locale, validation_locale = split_locales(locale)
    
    register_array(name, default, option_locale) do |values|
      success = validate_files(values, validation_locale)
      success = code.call(values, success) if code
      success
    end  
  end
  
  #---
    
  def register_directory(name, default = nil, locale = nil, &code)
    name = name.to_sym
    
    register_str(name, default, locale) do |value|
      success = validate_directory(value)
      success = code.call(value, success) if code
      success
    end
  end
  
  #---
  
  def register_directories(name, default = nil, locale = nil, &code)
    name = name.to_sym
    
    option_locale, validation_locale = split_locales(locale)
    
    register_array(name, default, option_locale) do |values|
      success = validate_directories(values, validation_locale)
      success = code.call(values, success) if code
      success
    end  
  end
  
  #---
  
  def register_plugin_type(namespace, name, default = nil, locale = nil, &code)
    name = name.to_sym
    
    option_locale, validation_locale = split_locales(locale)
    
    register_str(name, default, option_locale) do |value|
      success = validate_plugin_types(namespace, name, value, validation_locale)
      success = code.call(value, success) if code
      success
    end  
  end
  
  #---
  
  def register_plugin_types(namespace, name, default = nil, locale = nil, &code)
    name = name.to_sym
    
    option_locale, validation_locale = split_locales(locale)
    
    register_array(name, default, option_locale) do |values|
      success = validate_plugin_types(namespace, name, values, validation_locale)
      success = code.call(values, success) if code
      success
    end  
  end
  
  #---
  
  def register_plugin_provider(namespace, type, name, default = nil, locale = nil, &code)
    name = name.to_sym    
    
    option_locale, validation_locale = split_locales(locale)
    
    register_str(name, default, option_locale) do |value|
      success = validate_plugin_providers(namespace, type, name, value, validation_locale)
      success = code.call(value, success) if code
      success
    end  
  end
  
  #---
  
  def register_plugin_providers(namespace, type, name, default = nil, locale = nil, &code)
    name = name.to_sym
    
    option_locale, validation_locale = split_locales(locale)
    
    register_array(name, default, option_locale) do |values|
      success = validate_plugin_providers(namespace, type, name, values, validation_locale)
      success = code.call(values, success) if code
      success
    end  
  end
  
  #---
  
  def register_plugin(namespace, type, name, default = nil, locale = nil, &code)
    name = name.to_sym
    
    option_locale, validation_locale = split_locales(locale)
    
    register_str(name, default, option_locale) do |value|
      success = validate_plugins(namespace, type, name, value, validation_locale)
      success = code.call(value, success) if code
      success
    end  
  end
  
  #---
  
  def register_plugins(namespace, type, name, default = nil, locale = nil, &code)
    name = name.to_sym
    
    option_locale, validation_locale = split_locales(locale)
    
    register_array(name, default, option_locale) do |values|
      success = validate_plugins(namespace, type, name, values, validation_locale)
      success = code.call(values, success) if code
      success
    end  
  end
  
  #---
    
  def register_project_provider(name, default = nil, locale = nil, &code)
    register_plugin_provider(:nucleon, :project, name.to_sym, default, locale, &code)
  end
  
  #---
    
  def register_project_providers(name, default = nil, locale = nil, &code)
    register_plugin_providers(:nucleon, :project, name.to_sym, default, locale, &code)
  end
  
  #---
    
  def register_project(name, default = nil, locale = nil, &code)
    register_plugin(:nucleon, :project, name.to_sym, default, locale, &code)
  end
  
  #---
    
  def register_projects(name, default = nil, locale = nil, &code)
    register_plugins(:nucleon, :project, name.to_sym, default, locale, &code)    
  end
  
  #---
    
  def register_translator_provider(name, default = nil, locale = nil, &code)
    register_plugin_provider(:nucleon, :translator, name.to_sym, default, locale, &code)
  end
  
  #---
    
  def register_translator_providers(name, default = nil, locale = nil, &code)
    register_plugin_providers(:nucleon, :translator, name.to_sym, default, locale, &code)
  end
  
  #---
    
  def register_translator(name, default = nil, locale = nil, &code)
    register_plugin(:nucleon, :translator, name.to_sym, default, locale, &code)
  end
  
  #---
    
  def register_translators(name, default = nil, locale = nil, &code)
    register_plugins(:nucleon, :translators, name.to_sym, default, locale, &code) 
  end
  
  #-----------------------------------------------------------------------------
  # Validators
  
  def validate_file(file_name, locale = nil)
    success = file_name.nil? || File.exists?(file_name)
    warn(locale, { :file => file_name }) unless success
    success  
  end
  
  #---
  
  def validate_files(file_names, locale = nil)
    success = true
    
    array(file_names).each do |file_name|
      test    = validate_file(file_name, locale)
      success = false unless test
    end
    success  
  end
  
  #---
  
  def validate_directory(dir_name, locale = nil)
    success = dir_name.nil? || File.directory?(dir_name)
    warn(locale, { :directory => dir_name }) unless success
    success 
  end
  
  #---
  
  def validate_directories(dir_names, locale = nil)
    success = true
    
    array(dir_names).each do |dir_name|
      test    = validate_directory(dir_name, locale)
      success = false unless test
    end
    success  
  end
  
  #---
    
  def validate_plugin_types(namespace, name, values, locale = nil)
    loaded_plugin_types = Nucleon.loaded_plugins(namespace).keys
    success             = true
    locale              = "validation.#{name}" unless locale
    
    array(values).each do |value|
      if ! loaded_plugin_types.include?(value.to_sym)
        warn(locale, { :value => value, :choices => loaded_plugin_types.join(", ") })
        success = false
      end
    end      
    success  
  end
  
  #---
  
  def validate_plugin_providers(namespace, type, name, values, locale = nil)
    loaded_plugin_providers = Nucleon.loaded_plugins(namespace, type).keys
    success                 = true
    locale                  = "validation.#{name}" unless locale
    
    array(values).each do |value|
      if ! loaded_plugin_providers.include?(value.to_sym)
        warn(locale, { :value => value, :choices => loaded_plugin_providers.join(", ") })
        success = false
      end
    end      
    success  
  end
  
  #---
  
  def validate_plugins(namespace, type, name, values, locale = nil)
    plugin_class   = Nucleon.plugin_class(namespace, type)
    loaded_plugins = Nucleon.loaded_plugins(namespace, type)
    success        = true    
    locale         = "validation.#{name}" unless locale
        
    array(values).each do |value|
      if info = plugin_class.translate_reference(value)
        if ! loaded_plugins.keys.include?(info[:provider].to_sym)
          warn(locale, Util::Data.merge([ info, { :value => value, :choices => loaded_plugins.keys.join(", ") } ]))
          success = false
        end
      end
    end      
    success
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def split_locales(locale)
    option_locale     = nil
    validation_locale = nil
    
    if locale.is_a?(Array)
      option_locale     = locale[0]
      validation_locale = locale[1] if locale.size > 1
    else
      option_locale     = locale
    end
    [ option_locale, validation_locale ]
  end
end
end
end
end

