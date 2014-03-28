
module Nucleon
module Action
class Create < Nucleon.plugin_class(:action)
  
  include Mixin::Action::Project
 
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
      info('nucleon.actions.create.start')
      
      project       = project_load(settings[:path], true, true)
      myself.status = code.project_failure unless project
    end
  end
end
end
end
