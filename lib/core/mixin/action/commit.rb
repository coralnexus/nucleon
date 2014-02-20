
module Nucleon
module Mixin
module Action
module Commit
        
  #-----------------------------------------------------------------------------
  # Options
        
  def commit_options(parser, optional = true)
    if optional
      parser.option_bool(:commit, false, 
        '--commit', 
        'nucleon.core.mixins.commit.options.commit'
      )
    else
      parser.options[:commit] = true
    end
         
    parser.option_bool(:allow_empty, false,
      '--empty', 
      'nucleon.core.mixins.commit.options.empty'
    )
    parser.option_bool(:propogate, false,
      '--propogate', 
      'nucleon.core.mixins.commit.options.propogate'
    )          
    parser.option_str(:message, '',
      '--message COMMIT_MESSAGE',  
      'nucleon.core.mixins.commit.options.message'
    )
    parser.option_str(:author, nil,
      '--author COMMIT_AUTHOR',  
      'nucleon.core.mixins.commit.options.author'
    )         
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
        :propogate   => settings[:propogate]
      }))
    end
    success
  end
end
end
end
end

