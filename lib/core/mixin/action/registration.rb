
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
    
  def register_file(name, default = nil)
    name = name.to_sym
    
    register name, :str, default do |value|
      validate_file(value)
    end
  end
  
  #---
    
  def register_directory(name, default = nil)
    name = name.to_sym
    
    register name, :str, default do |value|
      validate_directory(value)
    end
  end
  
  #---
    
  def register_project(name, default = nil)
    name = name.to_sym
    
    register name, :str, default do |value|
      validate_plugins(:nucleon, :project, name, value)
    end
  end
  
  #---
    
  def register_projects(name, default = nil)
    name = name.to_sym
    
    register name, :array, default do |values|
      validate_plugins(:nucleon, :project, name, values)
    end
  end
  
  #---
    
  def register_translator(name, default = nil)
    name = name.to_sym
    
    register name, :str, default do |value|
      validate_plugins(:nucleon, :translator, name, value)
    end
  end
  
  #---
    
  def register_translators(name, default = nil)
    name = name.to_sym
    
    register name, :array, default do |values|
      validate_plugins(:nucleon, :translator, name, values)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Validators
  
  def validate_file(file_name)
    file_name.nil? || File.exists?(file_name)  
  end
  
  #---
  
  def validate_directory(dir_name)
    dir_name.nil? || File.directory?(dir_name)
  end
end
end
end
end

