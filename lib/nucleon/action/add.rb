
module Nucleon
module Action
class Add < Nucleon.plugin_class(:action)
  
  include Mixin::Action::Project
  include Mixin::Action::Push
 
  #-----------------------------------------------------------------------------
  # Settings
  
  def configure
    super do    
      codes :project_failure,
            :add_failure,
            :push_failure
            
      register :sub_path, :str, nil
      register :editable, :bool, false
      
      project_config
      push_config
    end
  end
  
  #---
  
  def arguments
    [ :sub_path, :project_reference ]
  end

  #-----------------------------------------------------------------------------
  # Action operations
   
  def execute
    super do
      info('nucleon.actions.add.start')
      
      if project = project_load(Dir.pwd, false)
        sub_info = project.translate_reference(settings[:project_reference], settings[:editable])
        sub_path = settings[:sub_path]
          
        if sub_info
          sub_url      = sub_info[:url]
          sub_revision = sub_info[:revision]
        else
          sub_url      = settings[:project_reference]
          sub_revision = nil
        end
          
        if project.add_subproject(sub_path, sub_url, sub_revision)
          myself.status = code.push_failure unless push(project)
        else
          myself.status = code.add_failure
        end
      else
        myself.status = code.project_failure               
      end
    end
  end
end
end
end
