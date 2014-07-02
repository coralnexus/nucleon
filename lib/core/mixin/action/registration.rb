
module Nucleon
module Mixin
module Action
module Registration
        
  #-----------------------------------------------------------------------------
  # Options
    
  def register_project(name, default = nil)
    name = "#{name}_project"
    
    register name, :str, default do |value|
      validate_plugins(:nucleon, :project, name, value)
    end
  end
  
  #---
    
  def register_projects(name, default = nil)
    name = "#{name}_projects"
    
    register name, :array, default do |values|
      validate_plugins(:nucleon, :project, name, values)
    end
  end
end
end
end
end

