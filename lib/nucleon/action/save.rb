
module Nucleon
module Action
class Save < Plugin::Action
  
  include Mixin::Action::Project
  include Mixin::Action::Commit
  include Mixin::Action::Push
 
  #-----------------------------------------------------------------------------
  # Save action interface
  
  def normalize
    super('nucleon save [ <file> ... ]')    
    
    codes :project_failure => 20,
          :commit_failure  => 21,
          :push_failure    => 22
  end

  #-----------------------------------------------------------------------------
  # Action operations
  
  def parse(parser)
    parser.arg_array(:files, '.', 
      'nucleon.core.actions.save.options.files'
    )
    project_options(parser, true, false)
    commit_options(parser, false)
    push_options(parser, true)
  end
  
  #---
   
  def execute          
    super do |node, network, status|
      info('nucleon.core.actions.save.start')
          
      if project = project_load(Dir.pwd, false)
        if commit(project, settings[:files])
          status = code.push_failure unless push(project)
        else
          status = code.commit_failure
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
