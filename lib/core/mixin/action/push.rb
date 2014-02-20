
module Nucleon
module Mixin
module Action
module Push
        
  #-----------------------------------------------------------------------------
  # Options
        
  def push_options(parser, optional = true)
    if optional
      parser.option_bool(:push, false, 
        '--push', 
        'nucleon.core.mixins.push.options.push'
      )
    else
      parser.options[:push] = true
    end
          
    parser.option_bool(:propogate, false,
      '--propogate', 
      'nucleon.core.mixins.push.options.propogate'
    )          
    parser.option_str(:remote, :edit,
      '--remote PROJECT_REMOTE',  
      'nucleon.core.mixins.push.options.remote'
    )
    parser.option_str(:revision, :master,
      '--revision PROJECT_REVISION',  
      'nucleon.core.mixins.push.options.revision'
    )         
  end
        
  #-----------------------------------------------------------------------------
  # Operations
        
  def push(project, remote = :edit)
    success = true
          
    if project && settings[:push]
      success = project.push(settings[:remote], extended_config(:push, {
        :revision  => settings[:revision],
        :propogate => settings[:propogate]
      }))
    end
    success
  end
end
end
end
end

