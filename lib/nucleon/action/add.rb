
module Nucleon
module Action
class Add < Nucleon.plugin_class(:action)
  
  include Mixin::Action::Project
  include Mixin::Action::Push
 
  #-----------------------------------------------------------------------------
  # Settings
  
  def configure
    super do    
      codes :project_failure,
            :add_failure,
            :push_failure
      
      register :path, :str, Dir.pwd        
      
      register :sub_path, :str, nil
      register :sub_reference, :str, nil do |value|
        success = true
        if info = Nucleon.plugin_class(:project).translate_reference(value)
          if ! Nucleon.loaded_plugins(:project).keys.include?(info[:provider].to_sym)
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
      register :editable, :bool, false
      
      project_config
      push_config
    end
  end
  
  #---
  
  def arguments
    [ :sub_path, :sub_reference ]
  end

  #-----------------------------------------------------------------------------
  # Action operations
   
  def execute
    super do
      info('nucleon.actions.add.start')
      
      if project = project_load(settings[:path], false)
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
          myself.status = code.push_failure unless push(project)
        else
          myself.status = code.add_failure
        end
      else
        myself.status = code.project_failure               
      end
    end
  end
end
end
end
