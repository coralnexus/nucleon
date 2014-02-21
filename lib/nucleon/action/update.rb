
module Nucleon
module Action
class Update < Nucleon.plugin_class(:action)
  
  include Mixin::Action::Project
 
  #-----------------------------------------------------------------------------
  # Settings
  
  def configure
    super do
      codes :project_failure
      
      project_options
    end
  end
  
  #-----------------------------------------------------------------------------
  # Operations
   
  def execute
    super do |node, network|
      info('nucleon.actions.update.start')
      
      project       = project_load(Dir.pwd, true)
      myself.status = code.project_failure unless project
    end
  end
end
end
end
