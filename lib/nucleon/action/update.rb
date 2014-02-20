
module Nucleon
module Action
class Update < Plugin::Action
  
  include Mixin::Action::Project
 
  #-----------------------------------------------------------------------------
  # Update action interface
  
  def normalize
    super('nucleon update')    
    
    codes :project_failure => 20
  end
  
  #-----------------------------------------------------------------------------
  # Action operations
  
  def parse(parser)
    project_options(parser, true, true)
  end
  
  #---
   
  def execute
    super do |node, network, status|
      info('nucleon.core.actions.update.start')
      
      project = project_load(Dir.pwd, true)
      status  = code.project_failure unless project
      status
    end
  end
end
end
end
