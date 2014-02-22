
module Nucleon
module Mixin
module Action
module Push
        
  #-----------------------------------------------------------------------------
  # Settings
        
  def push_config(optional = true)
    
    if optional
      register :push, :bool, false, 'nucleon.core.mixin.action.push.options.push'
    else
      settings[:push] = true
    end
    
    register :remote, :str, :edit, 'nucleon.core.mixin.action.push.options.remote'
    register :revision, :str, :master, 'nucleon.core.mixin.action.push.options.revision'
    
    register :propogate_push, :bool, false, 'nucleon.core.mixin.action.push.options.propogate_push'
  end
        
  #-----------------------------------------------------------------------------
  # Operations
        
  def push(project, remote = :edit)
    success = true
          
    if project && settings[:push]
      success = project.push(settings[:remote], extended_config(:push, {
        :revision  => settings[:revision],
        :propogate => settings[:propogate_push]
      }))
    end
    success
  end
end
end
end
end

