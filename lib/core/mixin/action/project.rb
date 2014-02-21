
module Nucleon
module Mixin
module Action
module Project
        
  #-----------------------------------------------------------------------------
  # Settings
        
  def project_config
    project_plugins = CORL.loaded_plugins(:project)
    
    register :project_provider, :str, :git do |value|
      value = value.to_sym
      
      unless project_plugins.keys.include?(value)
        warn('corl.core.mixins.action.project.errors.project_provider', { :value => value, :choices => project_plugins.keys.join(", ") })
        next false
      end
      true
    end
    register :project_reference, :str, nil do |value|
      success = true
      if info = CORL.plugin_class(:project).translate_reference(value)
        if ! project_plugins.keys.include?(info[:provider].to_sym)
          warn('corl.core.mixins.action.project.errors.project_reference', { 
            :value     => value, 
            :provider  => info[:provider],  
            :reference => info[:reference],
            :url       => info[:url],
            :revision  => info[:revision] 
          })
          success = false
        end
      end
      success
    end
    register :revision, :str, :master
  end
        
  #-----------------------------------------------------------------------------
  # Operations
        
  def project_load(root_dir, update = false)
        
    # 1. Set a default project provider (reference can override)
    # 2. Get project from root directory
    # 3. Initialize project if not yet initialized
    # 4. Set remote if needed
    # 5. Checkout revision if needed
    # 6. Pull down updates if requested
          
    return Nucleon.project(extended_config(:project, {
      :provider  => settings[:project_provider],
      :directory => root_dir,
      :url       => settings[:reference],
      :revision  => settings[:revision],
      :pull      => update
    }))
  end       
end
end
end
end

