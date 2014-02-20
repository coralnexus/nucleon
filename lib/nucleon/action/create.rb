
module Nucleon
module Action
class Create < Plugin::Action
 
  #-----------------------------------------------------------------------------
  # Create action interface
  
  def normalize
    super('nucleon create [ <project:::reference> ]')    
    
    codes :project_failure => 20
  end
 
  #-----------------------------------------------------------------------------
  # Action operations
  
  def parse(parser)
    parser.option_str(:path, Dir.pwd, 
      '--path PROJECT_DIR', 
      'nucleon.core.actions.create.options.path'
    )
    parser.option_str(:revision, :master, 
      '--revision REVISION/BRANCH', 
      'nucleon.core.actions.create.options.revision'
    )
    parser.arg_str(:reference, 
      'github:::coralnexus/puppet-cloud-template', 
      'nucleon.core.actions.create.options.reference'
    )
  end
  
  #---
   
  def execute
    super do |node, network, status|
      info('nucleon.core.actions.create.start')
      
      project = Nucleon.project(extended_config(:project, {
        :create    => true,
        :directory => settings[:path],
        :url       => settings[:reference],
        :revision  => settings[:revision],
        :pull      => true
      }))
      
      project ? status : code.project_failure
    end
  end
end
end
end
