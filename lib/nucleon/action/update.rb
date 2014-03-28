
module Nucleon
module Action
class Update < Nucleon.plugin_class(:action)
  
  include Mixin::Action::Project
 
  #-----------------------------------------------------------------------------
  # Settings
  
  def configure
    super do
      codes :project_failure
      
      register :path, :str, Dir.pwd       
      project_config
    end
  end
  
  #-----------------------------------------------------------------------------
  # Operations
   
  def execute
    super do
      info('nucleon.actions.update.start')
      
      project       = project_load(settings[:path], false, true)
      myself.status = code.project_failure unless project
    end
  end
end
end
end
