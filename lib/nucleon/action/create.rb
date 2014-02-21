
module Nucleon
module Action
class Create < Nucleon.plugin_class(:action)
 
  #-----------------------------------------------------------------------------
  # Settings
  
  def configure
    super do    
      codes :project_failure
      
      register :path, :str, Dir.pwd
      
      project_config
    end
  end
  
  #---
  
  def arguments
    [ :project_reference ]
  end
 
  #-----------------------------------------------------------------------------
  # Operations
   
  def execute
    super do |node, network|
      info('nucleon.actions.create.start')
      
      project = Nucleon.project(extended_config(:project, {
        :create    => true,
        :directory => settings[:path],
        :url       => settings[:project_reference],
        :revision  => settings[:revision],
        :pull      => true
      }), settings[:project_provider])
      
      myself.status = code.project_failure unless project
    end
  end
end
end
end
