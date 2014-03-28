
module Nucleon
module Action
class Remove < Nucleon.plugin_class(:action)
  
  include Mixin::Action::Project
  include Mixin::Action::Push
 
  #-----------------------------------------------------------------------------
  # Settings
  
  def configure
    super do    
      codes :project_failure,
            :delete_failure,
            :push_failure
      
      register :path, :str, Dir.pwd       
      register :sub_path, :str, nil
      
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
      info('nucleon.actions.remove.start')
      
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
