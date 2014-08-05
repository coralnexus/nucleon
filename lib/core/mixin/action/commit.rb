
module Nucleon
module Mixin
module Action
module Commit
        
  #-----------------------------------------------------------------------------
  # Settings
        
  def commit_config(optional = true)
    
    if optional
      register_bool :commit, :false, 'nucleon.core.action.commit.options.commit'
    else
      settings[:commit] = true
    end
    
    register_bool :allow_empty, true, 'nucleon.core.action.commit.options.allow_empty'
    register_bool :propogate_commit, false, 'nucleon.core.mixin.action.commit.options.propogate_commit'
    
    register_str :message, '', 'nucleon.core.action.commit.options.message'
    
    register_str :author, nil, 'nucleon.core.mixin.action.commit.options.author' do |value|
      if value.nil? || value.strip =~ /^[A-Za-z\s]+<\s*[^@]+@[^>]+\s*>$/
        next true
      end
      warn('corl.core.mixins.action.commit.errors.author', { :value => value })
      false
    end
  end
  
  #---
  
  def commit_ignore
    [ :commit, :allow_empty, :propogate_commit, :message, :author ]
  end
        
  #-----------------------------------------------------------------------------
  # Operations
        
  def commit(project, files = '.')
    success = true
          
    if project && settings[:commit]
      success = project.commit(files, extended_config(:commit, {
        :allow_empty => settings[:allow_empty],
        :message     => settings[:message],
        :author      => settings[:author],
        :propogate   => settings[:propogate_commit]
      }))
    end
    success
  end
end
end
end
end

