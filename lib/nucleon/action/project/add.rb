
module Nucleon
module Action
module Project
class Add < Nucleon.plugin_class(:nucleon, :action)
  
  include Mixin::Action::Project
  include Mixin::Action::Push
  
  #-----------------------------------------------------------------------------
  # Info
  
  def self.describe
    super(:project, :add, 700)
  end
 
  #-----------------------------------------------------------------------------
  # Settings
  
  def configure
    super do    
      codes :project_failure,
            :add_failure,
            :push_failure
      
      register_str :path, Dir.pwd        
      register_str :sub_path, nil
      
      register_project :sub_reference, nil
      
      register_bool :editable
      
      project_config
      push_config
    end
  end
  
  #---
  
  def arguments
    [ :sub_path, :sub_reference ]
  end

  #-----------------------------------------------------------------------------
  # Action operations
   
  def execute
    super do
      info('start')
      
      if project = project_load(settings[:path], false)
        sub_info = project.translate_reference(settings[:sub_reference], settings[:editable])
        sub_path = settings[:sub_path]
          
        if sub_info
          sub_url      = sub_info[:url]
          sub_revision = sub_info[:revision]
        else
          sub_url      = settings[:sub_reference]
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
end
