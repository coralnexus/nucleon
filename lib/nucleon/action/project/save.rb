
module Nucleon
module Action
module Project
class Save < Nucleon.plugin_class(:nucleon, :action)
  
  include Mixin::Action::Project
  include Mixin::Action::Commit
  include Mixin::Action::Push
  
  #-----------------------------------------------------------------------------
  # Info
  
  def self.describe
    super(:project, :save, 800)
  end
 
  #-----------------------------------------------------------------------------
  # Settings
  
  def configure
    super do 
      codes :project_failure,
            :commit_failure,
            :push_failure
      
      register_str :path, Dir.pwd
      register_files :files, '.'
      
      project_config
      commit_config(false)
      push_config
    end
  end
  
  #---
  
  def arguments
    [ :files ]
  end

  #-----------------------------------------------------------------------------
  # Operations
   
  def execute          
    super do
      info('start')
          
      if project = project_load(settings[:path], false, false)
        if commit(project, settings[:files])
          myself.status = code.push_failure unless push(project)
        else
          myself.status = code.commit_failure
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
