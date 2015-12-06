
module Nucleon
module Mixin
module Action
module Project

  #-----------------------------------------------------------------------------
  # Settings

  def project_config
    register_project_provider :project_provider, nil, [
      'nucleon.core.mixin.action.project.options.project_provider',
      'nucleon.core.mixin.action.project.errors.project_provider'
    ]
    register_project :project_reference, nil, [
      'nucleon.core.mixin.action.project.options.project_reference',
      'nucleon.core.mixin.action.project.errors.project_reference'
    ]
    register_str :project_revision, :master, 'nucleon.core.mixin.action.project.options.project_revision'
  end

  #---

  def project_ignore
    [ :project_provider, :project_reference, :project_revision ]
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
      :create         => create,
      :provider       => settings[:project_provider],
      :directory      => root_dir,
      :url            => settings[:project_reference],
      :revision       => settings[:project_revision],
      :pull           => update,
      :nucleon_resave => true,
      :nucleon_cache  => false
    }))
  end
end
end
end
end

