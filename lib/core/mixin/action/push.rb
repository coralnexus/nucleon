
module Nucleon
module Mixin
module Action
module Push
        
  #-----------------------------------------------------------------------------
  # Settings
        
  def push_config(optional = true)
    
    if optional
      register_bool :push, false, 'nucleon.core.mixin.action.push.options.push'
    else
      settings[:push] = true
    end
    
    register_bool :pull, true, 'nucleon.core.mixin.action.push.options.pull'
    
    register_bool :propogate_push, false, 'nucleon.core.mixin.action.push.options.propogate_push'
    
    register_str :remote, :edit, 'nucleon.core.mixin.action.push.options.remote'
    register_str :revision, :master, 'nucleon.core.mixin.action.push.options.revision'    
  end
  
  #---
  
  def push_ignore
    [ :push, :pull, :propogate_push, :remote, :revision ]
  end
        
  #-----------------------------------------------------------------------------
  # Operations
        
  def push(project, remote = :edit)
    success = true
          
    if project && settings[:push]
      success = project.push(settings[:remote], extended_config(:push, {
        :revision  => settings[:revision],
        :propogate => settings[:propogate_push],
        :no_pull   => ! settings[:pull]
      }))
    end
    success
  end
end
end
end
end

