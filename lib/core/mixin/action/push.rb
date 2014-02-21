
module Nucleon
module Mixin
module Action
module Push
        
  #-----------------------------------------------------------------------------
  # Settings
        
  def push_config(optional = true)
    
    if optional
      register :push, :bool, false
    else
      settings[:push] = true
    end
    
    register :propogate_push, :bool, false
    
    register :remote, :str, :edit
    register :revision, :str, :master
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

