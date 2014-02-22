
module Nucleon
module Mixin
module Action
module Commit
        
  #-----------------------------------------------------------------------------
  # Settings
        
  def commit_config(optional = true)
    
    if optional
      register :commit, :bool, :false, 'nucleon.core.mixin.action.commit.options.commit'
    else
      settings[:commit] = true
    end
    
    register :allow_empty, :bool, false, 'nucleon.core.mixin.action.commit.options.allow_empty'
    register :propogate_commit, :bool, false, 'nucleon.core.mixin.action.commit.options.propogate_commit'
    
    register :message, :str, '', 'nucleon.core.mixin.action.commit.options.message'
    
    register :author, :str, nil, 'nucleon.core.mixin.action.commit.options.author' do |value|
      if value.nil? || value.strip =~ /^[A-Za-z\s]+<\s*[^@]+@[^>]+\s*>$/
        next true
      end
      warn('corl.core.mixins.action.commit.errors.author', { :value => value })
      false
    end
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

