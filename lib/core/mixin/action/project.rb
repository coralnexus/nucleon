
module Nucleon
module Mixin
module Action
module Project
        
  #-----------------------------------------------------------------------------
  # Settings
        
  def project_config
    project_plugins = Nucleon.loaded_plugins(:nucleon, :project)
    
    register :project_provider, :str, :git, 'nucleon.core.mixin.action.project.options.project_provider' do |value|
      value = value.to_sym
      
      unless project_plugins.keys.include?(value)
        warn('nucleon.core.mixin.action.project.errors.project_provider', { :value => value, :choices => project_plugins.keys.join(", ") })
        next false
      end
      true
    end
    register :project_reference, :str, nil, 'nucleon.core.mixin.action.project.options.project_reference' do |value|
      success = true
      if info = Nucleon.plugin_class(:nucleon, :project).translate_reference(value)
        if ! project_plugins.keys.include?(info[:provider].to_sym)
          warn('nucleon.core.mixin.action.project.errors.project_reference', { 
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
    register :project_revision, :str, :master, 'nucleon.core.mixin.action.project.options.project_revision'
  end
        
  #-----------------------------------------------------------------------------
  # Operations
        
  def project_load(root_dir, create = false, update = false)
        
    # 1. Set a default project provider (reference can override)
    # 2. Get project from root directory
    # 3. Initialize project if not yet initialized if requested
    # 4. Set remote if needed
    # 5. Checkout revision if needed
    # 6. Pull down updates if requested
          
    return Nucleon.project(extended_config(:project, {
      :create    => create,
      :provider  => settings[:project_provider],
      :directory => root_dir,
      :url       => settings[:project_reference],
      :revision  => settings[:project_revision],
      :pull      => update
    }))
  end       
end
end
end
end

