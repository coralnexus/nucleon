
module Nucleon
module Project
class Git < Plugin::Project
 
  #-----------------------------------------------------------------------------
  # Project plugin interface
   
  def normalize(reload)
    super   
  end
  
  #-----------------------------------------------------------------------------
  # Git interface (local)
   
  def ensure_git(reset = false)
    if reset || @git_lib.nil?
      @git_lib = nil
      
      if directory.empty?
        logger.warn("Can not manage Git project at #{directory} as it does not exist")  
      else
        logger.debug("Ensuring Git instance to manage #{directory}")
        @git_lib = Util::Git.new(directory)
        
        if ! @git_lib.nil? && get(:create, false)
          unless File.directory?(directory) && @git_lib.git.exist?
            FileUtils.mkdir_p(directory) unless File.directory?(directory)
            @git_lib.git.init({ :bare => false })
          end
        end
      end
    end
    return myself
  end
  protected :ensure_git
       
  #-----------------------------------------------------------------------------
  # Checks
   
  def can_persist?
    ensure_git
    return true unless @git_lib.nil?
    return false
  end
 
  #---
          
  def top?(path)
    git_dir = File.join(path, '.git')
    if File.exist?(git_dir)
      return true if File.directory?(git_dir)
    elsif File.exist?(path) && (path =~ /\.git$/ && File.exist?(File.join(path, 'HEAD')))
      return true
    end
    return false
  end
    
  #---
          
  def subproject?(path)
    git_dir = File.join(path, '.git')
    if File.exist?(git_dir)
      unless File.directory?(git_dir)
        git_dir = Util::Disk.read(git_dir)        
        unless git_dir.nil?
          git_dir = git_dir.gsub(/^gitdir\:\s*/, '').strip
          return true if File.directory?(git_dir)
        end  
      end
    end
    return false
  end
  
  #---
      
  def project_directory?(path, require_top_level = false)
    path    = File.expand_path(path)
    git_dir = File.join(path, '.git')

    if File.exist?(git_dir)
      if File.directory?(git_dir)
        return true
      elsif ! require_top_level
        git_dir = Util::Disk.read(git_dir)
        unless git_dir.nil?
          git_dir = git_dir.gsub(/^gitdir\:\s*/, '').strip
          return true if File.directory?(git_dir)
        end  
      end
    elsif File.exist?(path) && (path =~ /\.git$/ && File.exist?(File.join(path, 'HEAD')))
      return true
    end
    return false
  end
  
  #---
  
  def new?(reset = false)
    if get(:new, nil).nil? || reset
      set(:new, git.native(:rev_parse, { :all => true }).empty?)  
    end
    get(:new, false)
  end
   
  #-----------------------------------------------------------------------------
  # Property accessors / modifiers
  
  def lib
    return @git_lib
  end
 
  #---
  
  def git
    return lib.git if can_persist?
    return nil
  end
  protected :git
    
  #---
   
  def set_location(directory)
    super do
      ensure_git(true)
    end
    return myself
  end
  
  #---
  
  def config(name, options = {})
    return super do |config|
      git.config(config.export, name)
    end
  end
  
  #---
  
  def set_config(name, value, options = {})
    return super do |config, processed_value|
      git.config(config.export, name, processed_value)
    end
  end
  
  #---
  
  def delete_config(name, options = {})
    return super do |config|
      git.config(config.import({ :remove_section => true }).export, name)
    end
  end
  
  #---
 
  def subproject_config(options = {})
    return super do |config|
      result = {}
      
      if new?
        logger.debug("Project has no sub project configuration yet (has not been committed to)")  
      else
        commit = lib.commit(revision)
        blob   = commit.tree/'.gitmodules' unless commit.nil?
          
        if blob
          logger.debug("Houston, we have a Git blob!")
        
          lines   = blob.data.gsub(/\r\n?/, "\n" ).split("\n")
          current = nil

          lines.each do |line|
            if line =~ /^\[submodule "(.+)"\]$/
              current         = $1
              result[current] = {}
              result[current]['id'] = (commit.tree/current).id
            
              logger.debug("Reading: #{current}")
      
            elsif line =~ /^\t(\w+) = (.+)$/
              result[current][$1]   = $2
              result[current]['id'] = (commit.tree/$2).id if $1 == 'path'
            end
          end
        end
      end
      result
    end
  end
 
  #-----------------------------------------------------------------------------
  # Basic Git operations
  
  def load_revision
    return super do
      if new?
        logger.debug("Project has no current revision yet (has not been committed to)")
        nil
        
      else
        current_revision = git.native(:rev_parse, { :abbrev_ref => true }, 'HEAD').strip
      
        logger.debug("Current revision: #{current_revision}")
        current_revision
      end
    end
  end
  
  #---
  
  def checkout(revision)
    return super do |success|
      if new?
        logger.debug("Project can not be checked out (has not been committed to)")  
      else
        unless lib.bare
          success = safe_exec(false) do
            git.checkout({ :raise => true }, revision)
          end
        end
      end
      success  
    end
  end
  
  #---
  
  def commit(files = '.', options = {})
    return super do |config, time, user, message|
      safe_exec(false) do
        git.reset({}, 'HEAD') # Clear the index so we get a clean commit
      
        files = array(files)
      
        logger.debug("Adding files to Git index")
        
        git.add({ :raise => true }, files)                  # Get all added and updated files
        git.add({ :update => true, :raise => true }, files) # Get all deleted files
        
        commit_options = {
          :raise       => true, 
          :m           => "#{time} by <#{user}> - #{message}",
          :allow_empty => config.get(:allow_empty, false) 
        }
        commit_options[:author] = config[:author] if config.get(:author, false)
    
        logger.debug("Composing commit options: #{commit_options.inspect}")
        git.commit(commit_options)
        
        new?(true)
      end
    end   
  end

  #-----------------------------------------------------------------------------
  # Subproject operations
 
  def load_subprojects(options = {})
    return super do |project_path, data|
      File.exist?(File.join(project_path, '.git'))
    end
  end
  
  #---
  
  def add_subproject(path, url, revision, options = {})
    return super do |config|
      safe_exec(false) do
        branch_options = ''
        branch_options = [ '-b', config[:revision] ] if config.get(:revision, false)
      
        path = config[:path]
        url  = config[:url]
        
        git.submodule({ :raise => true }, 'add', *branch_options, url, path)
        
        config.set(:files, [ '.gitmodules', path ])
      end
    end  
  end
  
  #---
  
  def delete_subproject(path)
    return super do |config|
      safe_exec(false) do
        path          = config[:path]
        submodule_key = "submodule.#{path}"
      
        logger.debug("Deleting Git configurations for #{submodule_key}")
        delete_config(submodule_key)
        delete_config(submodule_key, { :file => '.gitmodules' })
      
        logger.debug("Cleaning Git index cache for #{path}")
        git.rm({ :cached => true }, path)
      
        logger.debug("Removing Git submodule directories")
        FileUtils.rm_rf(File.join(directory, path))
        FileUtils.rm_rf(File.join(git.git_dir, 'modules', path))
      
        config.set(:files, [ '.gitmodules', path ])
      end
    end  
  end
 
  #---
   
  def update_subprojects
    return super do
      safe_exec(false) do
        git.submodule({ :raise => true, :timeout => false }, 'update', '--init', '--recursive')
      end
    end
  end
         
  #-----------------------------------------------------------------------------
  # Remote operations
  
  def init_remotes
    return super do
      origin_url = config('remote.origin.url').strip
      
      logger.debug("Original origin remote url: #{origin_url}")
      origin_url
    end
  end
  
  #---
  
  def remote(name)
    return super do
      url = config("remote.#{name}.url").strip
      url.empty? ? nil : url
    end
  end
 
  #---
  
  def set_remote(name, url)
    return super do |processed_url|
      safe_exec(false) do
        git.remote({ :raise => true }, 'add', name.to_s, processed_url)
      end
    end
  end
  
  #---
  
  def add_remote_url(name, url, options = {})
    return super do |config, processed_url|
      safe_exec(false) do
        git.remote({
          :raise  => true,
          :add    => true,
          :delete => config.get(:delete, false),
          :push   => config.get(:push, false)
        }, 'set-url', name.to_s, processed_url)
      end
    end
  end
  
  #---
  
  def delete_remote(name)
    return super do
      if config("remote.#{name}.url").empty?
        logger.debug("Project can not delete remote #{name} because it does not exist yet")
        true  
      else
        safe_exec(false) do
          git.remote({ :raise => true }, 'rm', name.to_s)
        end
      end
    end
  end
  
  #---
    
  def syncronize(cloud, options = {})
    return super do |config|
      config.init(:remote_path, '/var/git')
      config.set(:add, true)
    end
  end
   
  #-----------------------------------------------------------------------------
  # SSH operations
 
  def pull(remote = :origin, options = {})
    return super do |config, processed_remote|
      flags = []
      flags << :tags if config.get(:tags, true)
      
      result = Nucleon.command({
        :command => :git,
        :data    => { 'git-dir=' => git.git_dir },
        :subcommand => {
          :command => :pull,
          :flags   => flags,
          :args    => [ processed_remote, config.get(:revision, get(:revision, :master)) ]
        }
      }, config.get(:provider, :bash)).exec(config) do |op, command, data|
        block_given? ? yield(op, command, data) : true
      end
      
      if result.status == code.success
        new?(true)
        true
      else
        false
      end    
    end
  end
  
  #---
    
  def push(remote = :edit, options = {})
    return super do |config, processed_remote|
      push_branch = config.get(:revision, '')
      
      flags = []
      flags << :all if push_branch.empty?
      flags << :tags if ! push_branch.empty? && config.get(:tags, true)
      
      result = Nucleon.command({
        :command => :git,
        :data => { 'git-dir=' => git.git_dir },
        :subcommand => {
          :command => :push,
          :flags => flags,
          :args => [ processed_remote, push_branch ]
        }
      }, config.get(:provider, :bash)).exec(config) do |op, command, data|
        block_given? ? yield(op, command, data) : true
      end
      
      result.status == code.success
    end
  end
 
  #-----------------------------------------------------------------------------
  # Utilities
  
  def translate_url(host, path, options = {})
    return super do |config|
      user = config.get(:user, 'git')
      auth = config.get(:auth, true)
      
      user + (auth ? '@' : '://') + host + (auth ? ':' : '/') + path
    end
  end
  
  #---
  
  def translate_edit_url(url, options = {})
    return super do |config|    
      if matches = url.strip.match(/^(https?|git)\:\/\/([^\/]+)\/(.+)/)
        protocol, host, path = matches.captures
        translate_url(host, path, config.import({ :auth => true }))
      end
    end
  end
end
end
end
