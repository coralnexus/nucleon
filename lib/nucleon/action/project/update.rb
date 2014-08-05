
module Nucleon
module Action
module Project
class Update < Nucleon.plugin_class(:nucleon, :action)
  
  include Mixin::Action::Project
  
  #-----------------------------------------------------------------------------
  # Info
  
  def self.describe
    super(:project, :update, 900)
  end
 
  #-----------------------------------------------------------------------------
  # Settings
  
  def configure
    super do
      codes :project_failure
      
      register_str :path, Dir.pwd       
      project_config
    end
  end
  
  #-----------------------------------------------------------------------------
  # Operations
   
  def execute
    super do
      info('start')
      
      project       = project_load(settings[:path], false, true)
      myself.status = code.project_failure unless project
    end
  end
end
end
end
end
