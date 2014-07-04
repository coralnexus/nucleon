
module Nucleon
module Mixin
module Action
module Registration
        
  #-----------------------------------------------------------------------------
  # Options
    
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
end
end
end
end

