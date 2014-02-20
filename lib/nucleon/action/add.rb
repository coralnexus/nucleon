
module Nucleon
module Action
class Add < Plugin::Action
  
  include Mixin::Action::Project
  include Mixin::Action::Push
 
  #-----------------------------------------------------------------------------
  # Add action interface
  
  def normalize
    super('nucleon add <subproject/path> <subproject:::reference>')    
    
    codes :project_failure => 20,
          :add_failure     => 21,
          :push_failure    => 22
  end

  #-----------------------------------------------------------------------------
  # Action operations
   
  def parse(parser)
    parser.arg_str(:sub_path, nil, 
      'nucleon.core.actions.add.options.sub_path'
    )
    parser.arg_str(:sub_reference, nil, 
      'nucleon.core.actions.add.options.sub_reference'
    )
    parser.option_bool(:editable, false, 
      '--editable', 
      'nucleon.core.actions.add.options.editable'
    )
    project_options(parser, true, true)
    push_options(parser, true)  
  end
  
  #---
   
  def execute
    super do |node, network, status|
      info('nucleon.core.actions.add.start')
      
      if project = project_load(Dir.pwd, false)
        sub_info = project.translate_reference(settings[:sub_reference], settings[:editable])
        sub_path = settings[:sub_path]
          
        if sub_info
          sub_url      = sub_info[:url]
          sub_revision = sub_info[:revision]
        else
          sub_url      = settings[:sub_reference]
          sub_revision = nil
        end
          
        if project.add_subproject(sub_path, sub_url, sub_revision)
          status = code.push_failure unless push(project)
        else
          status = code.add_failure
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
