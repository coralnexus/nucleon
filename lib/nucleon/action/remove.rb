
module Nucleon
module Action
class Remove < Plugin::Action
  
  include Mixin::Action::Project
  include Mixin::Action::Push
 
  #-----------------------------------------------------------------------------
  # Remove action interface
  
  def normalize
    super('nucleon remove <subproject/path>')    
    
    codes :project_failure => 20,
          :delete_failure  => 21,
          :push_failure    => 22
  end
 
  #-----------------------------------------------------------------------------
  # Action operations
  
  def parse(parser)
    parser.arg_str(:sub_path, nil, 
      'nucleon.core.actions.remove.options.sub_path'
    )
    project_options(parser, true, true)
    push_options(parser, true)
  end
  
  #---
   
  def execute
    super do |node, network, status|
      info('nucleon.core.actions.remove.start')
      
      if project = project_load(Dir.pwd, false)
        if project.delete_subproject(settings[:sub_path])
          status = code.push_failure unless push(project)
        else
          status = code.delete_failure
        end
      else
        status = code.project_failure  
      end      
      status
    end
  end
end
end
end
