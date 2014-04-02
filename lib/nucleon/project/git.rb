
module Nucleon
module Project
class Git < Plugin::Project
 
  #-----------------------------------------------------------------------------
  # Project plugin interface
   
  def normalize(reload)
    unless reload
      @cli = Util::Liquid.new do |method, args, &code|
        options = {}
        options = args.shift if args.length > 0
        git_exec(method, options, args, &code)  
      end
    end
    super    
  end
  
  #-----------------------------------------------------------------------------
  # Git interface (local)
   
  def ensure_git(reset = false)
    if reset || @repo.nil?
      if directory.empty?
        logger.warn("Can not manage Git project at #{directory} as it does not exist")  
      else
        logger.debug("Ensuring Git instance to manage #{directory}")
        @repo = Util::Git.load(directory, {
          :create => get(:create, false)
        })
      end
    end
    return myself
  end
  protected :ensure_git
       
  #-----------------------------------------------------------------------------
  # Checks
   
  def can_persist?
    ensure_git
    return true unless @repo.nil?
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
      result = cli.rev_parse({ :all => true })
      
      if result && result.status == code.success
        set(:new, result.output.empty?)
      end  
    end
    get(:new, false)
  end
   
  #-----------------------------------------------------------------------------
  # Property accessors / modifiers
  
  def repo
    return @repo if can_persist?
    return nil
  end
  protected :repo
  
  #---
  
  def cli
    @cli
  end
    
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
      result = cli.config(config.export, name)
      next Util::Data.value(result.output) if result.status == code.success
      nil
    end
  end
  
  #---
  
  def set_config(name, value, options = {})
    return super do |config, processed_value|
      result = cli.config(config.export, name, processed_value)
      result.status == code.success
    end
  end
  
  #---
  
  def delete_config(name, options = {})
    return super do |config|
      result = cli.config(config.import({ :remove_section => true }).export, name)
      result.status == code.success
    end
  end
  
  #---
 
  def subproject_config(options = {})
    return super do |config|
      result = {}
      
      if new?
        logger.debug("Project has no sub project configuration yet (has not been committed to)")  
      else
        gitmodules_file = File.join(directory, '.gitmodules')
        
        gitmodules_data = ''
        gitmodules_data = Util::Disk.read(gitmodules_file) if File.exists?(gitmodules_file)
          
        unless gitmodules_data.empty?
          logger.debug("Houston, we have some gitmodules!")
        
          lines   = gitmodules_data.gsub(/\r\n?/, "\n" ).split("\n")
          current = nil

          lines.each do |line|
            if line =~ /^\[submodule "(.+)"\]$/
              current         = $1
              result[current] = {}
            
              logger.debug("Reading: #{current}")
      
            elsif line =~ /^\s*(\w+)\s*=\s*(.+)\s*$/
              result[current][$1] = $2
            end
          end
        end
      end
      result
    end
  end
  
  #-----------------------------------------------------------------------------
  # Operations
    
  def init_cache
    ignore(cache.directory_name)   
  end
  
  #-----------------------------------------------------------------------------
  # Basic Git operations
  
  def ignore(files)
    super do
      ensure_in_gitignore(files)
      '.gitignore'
    end  
  end
  
  #---
  
  def load_revision
    return super do
      if new?
        logger.debug("Project has no current revision yet (has not been committed to)")
        nil        
      else
        current_revision = nil
        result           = cli.rev_parse({ :abbrev_ref => true }, 'HEAD')
        
        if result && result.status == code.success
          current_revision = result.output
        end
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
        unless repo.bare?
          result = cli.checkout({}, revision)
        end
      end
      result && result.status == code.success
    end
  end
  
  #---
  
  def commit(files = '.', options = {})
    return super do |config, time, user, message|
      cli.reset({}, 'HEAD') unless new? # Clear the index so we get a clean commit
      
      files = array(files)
      
      logger.debug("Adding files to Git index")
      
      cli.add({}, *files)                  # Get all added and updated files
      cli.add({ :update => true }, *files) # Get all deleted files
        
      commit_options = {
        :m           => "<#{user}> #{message}",
        :allow_empty => config.get(:allow_empty, false) 
      }
      commit_options[:author] = config[:author] if config.get(:author, false)
    
      logger.debug("Composing commit options: #{commit_options.inspect}")
      result = cli.commit(commit_options)
        
      if result.status == code.success
        new?(true)
        true
      else
        false
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
      branch_options = ''
      branch_options = [ '-b', config[:revision] ] if config.get(:revision, false)
      
      path = config[:path]
      url  = config[:url]
        
      result = cli.submodule({}, 'add', *branch_options, url, path)
        
      if result.status == code.success
        config.set(:files, [ '.gitmodules', path ]) 
        true
      else
        false
      end
    end  
  end
  
  #---
  
  def delete_subproject(path)
    return super do |config|
      path          = config[:path]
      submodule_key = "submodule.#{path}"
      
      logger.debug("Deleting Git configurations for #{submodule_key}")
      delete_config(submodule_key)
      delete_config(submodule_key, { :file => '.gitmodules' })
      
      logger.debug("Cleaning Git index cache for #{path}")
      cli.rm({ :cached => true }, path)
      
      logger.debug("Removing Git submodule directories")
      FileUtils.rm_rf(File.join(directory, path))
      FileUtils.rm_rf(File.join(repo.path, 'modules', path))
      
      config.set(:files, [ '.gitmodules', path ])
    end  
  end
 
  #---
   
  def update_subprojects(options = {})
    return super do |config|
      result = cli.submodule({}, 'update', '--init', '--recursive')
      result.status == code.success
    end
  end
         
  #-----------------------------------------------------------------------------
  # Remote operations
  
  def init_remotes
    return super do
      origin_url = config('remote.origin.url')
      
      logger.debug("Original origin remote url: #{origin_url}") if origin_url
      origin_url
    end
  end
  
  #---
  
  def remote(name)
    return super do
      url = config("remote.#{name}.url")
      url.nil? || url.empty? ? nil : url
    end
  end
 
  #---
  
  def set_remote(name, url)
    return super do |processed_url|
      result = cli.remote({}, 'add', name, processed_url)
      result.status == code.success
    end
  end
  
  #---
  
  def add_remote_url(name, url, options = {})
    return super do |config, processed_url|
      result = cli.remote({
        :add    => true,
        :delete => config.get(:delete, false),
        :push   => config.get(:push, false)
      }, 'set-url', name, processed_url)
      result.status == code.success
    end
  end
  
  #---
  
  def delete_remote(name)
    return super do
      remote = remote(name)
      if ! remote || remote.empty?
        logger.debug("Project can not delete remote #{name} because it does not exist yet")
        true  
      else
        result = cli.remote({}, 'rm', name)
        result.status == code.success
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
  
  def git_fetch(remote = :edit, options = {}, &block)
    config         = Config.ensure(options)
    local_revision = config.get(:revision, get(:revision, :master))
     
    result = cli.fetch({}, remote, &block)
       
    if result.status == code.success
      new?(true)
      checkout(local_revision)
    else
      false
    end 
  end
  protected :git_fetch
  
  #---
 
  def pull(remote = :edit, options = {}, &block)
    return super do |config, processed_remote|
      success = false
      
      if new? || get(:create, false)
        success = git_fetch(processed_remote, config)  
      else
        pull_options = {}
        pull_options[:tags] = true if config.get(:tags, true)
        
        local_revision = config.get(:revision, get(:revision, :master))
      
        if checkout(local_revision)
          result = cli.pull(pull_options, processed_remote, local_revision, &block)
      
          if result.status == code.success
            new?(true)
            success = true
          end
        end
      end
      success  
    end
  end
  
  #---
    
  def push(remote = :edit, options = {}, &block)
    return super do |config, processed_remote|
      push_branch = config.get(:revision, '')
      
      push_options = {}
      push_options[:all]  = true if push_branch.empty?
      push_options[:tags] = true if ! push_branch.empty? && config.get(:tags, true)
      
      result = cli.push(push_options, processed_remote, push_branch, &block)      
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
  
  #---
  
  def git_exec(command, options = {}, args = [])
    result = nil
    
    if can_persist?
      check_value = lambda do |value|
        next false if value.nil?
        next false unless value.is_a?(String) || value.is_a?(Symbol)
        next false if value.to_s.empty?
        true 
      end
      
      localize(repo.workdir) do
        flags          = []
        data           = {}
        processed_args = []
        
        options.each do |key, value|
          cli_option = key.to_s.gsub('_', '-')
          
          if value.is_a?(TrueClass) || value.is_a?(FalseClass) 
            flags << cli_option if value == true
            
          elsif check_value.call(value)
            data[cli_option] = value.to_s
          end
        end
        
        args.each do |value|
          if check_value.call(value)
            processed_args << value.to_s
          end
        end
        
        command_provider = get(:command_provider, Nucleon.type_default(:command))
        quiet            = get(:quiet, true)        
        
        result = Nucleon.command({
          :command => :git,
          :data    => { 'git-dir=' => repo.path },
          :subcommand => {
            :command => command.to_s.gsub('_', '-'),
            :flags   => flags,
            :data    => data,
            :args    => processed_args
          }
        }, command_provider).exec({ :quiet => quiet }) do |op, cli_command, cli_data|
          block_given? ? yield(op, cli_command, cli_data) : true
        end
      end
    end
    result
  end
  protected :git_exec
  
  #---
  
  def ensure_in_gitignore(files)
    files   = [ files ] unless files.is_a?(Array)
    changes = false
    
    gitignore_file = File.join(directory, '.gitignore')
    ignore_raw     = Util::Disk.read(gitignore_file)
    ignores        = []
    ignores        = ignore_raw.split("\n") if ignore_raw && ! ignore_raw.empty?
    
    files.each do |file|
      found = false
      unless ignores.empty?
        ignores.each do |ignore|
          if ignore.strip.match(/^#{file}\/?$/)
            found = true
          end  
        end
      end
      unless found
        ignores << file
        changes = true
      end 
    end
    Util::Disk.write(gitignore_file, ignores.join("\n")) if changes
  end
  protected :ensure_in_gitignore
end
end
end
