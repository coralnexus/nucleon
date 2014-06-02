
module Nucleon
module Action
module Project
class Create < Nucleon.plugin_class(:nucleon, :action)
  
  include Mixin::Action::Project
  
  #-----------------------------------------------------------------------------
  # Info
  
  def self.describe
    super(:project, :create, 1000)
  end
  
  #-----------------------------------------------------------------------------
  # Settings
  
  def configure
    super do    
      codes :project_failure
      
      register :path, :str, Dir.pwd      
      project_config
      
      config[:project_reference].default = ''
    end
  end
  
  #---
  
  def arguments
    [ :project_reference ]
  end
 
  #-----------------------------------------------------------------------------
  # Operations
   
  def execute
    super do
      info('nucleon.action.project.create.start')
      
      project       = project_load(settings[:path], true, true)
      myself.status = code.project_failure unless project
    end
  end
end
end
end
end
