
module Nucleon
module Action
module Project
class Remove < Nucleon.plugin_class(:nucleon, :action)
  
  include Mixin::Action::Project
  include Mixin::Action::Push
  
  #-----------------------------------------------------------------------------
  # Info
  
  def self.describe
    super(:project, :remove, 600)
  end
 
  #-----------------------------------------------------------------------------
  # Settings
  
  def configure
    super do    
      codes :project_failure,
            :delete_failure,
            :push_failure
      
      register_str :path, Dir.pwd       
      register_str :sub_path, nil
      
      project_config
      push_config
    end
  end
  
  #---
  
  def ignore
    [ :project_reference ]
  end
  
  def arguments
    [ :sub_path ]
  end
 
  #-----------------------------------------------------------------------------
  # Operations
  
  def execute
    super do
      info('start')
      
      if project = project_load(settings[:path], false)
        if project.delete_subproject(settings[:sub_path])
          myself.status = code.push_failure unless push(project)
        else
          myself.status = code.delete_failure
        end
      else
        myself.status = code.project_failure  
      end
    end
  end
end
end
end
end
