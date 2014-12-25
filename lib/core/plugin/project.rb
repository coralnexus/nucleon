
module Nucleon
module Plugin
class Project < Nucleon.plugin_class(:nucleon, :base)

  @@projects = {}

  #---

  def self.collection
    @@projects
  end

  #---

  def self.register_ids
    [ :name, :directory ]
  end

  #-----------------------------------------------------------------------------
  # Constructor / Destructor

  def self.open(directory, provider, options = {})
    config    = Config.ensure(options)
    directory = File.expand_path(Util::Disk.filename(directory))

    if ! @@projects.has_key?(directory) || config.get(:reset, false)
      logger.info("Creating new project at #{directory} with #{provider}")

      return Nucleon.project(config.import({
        :name      => directory,
        :directory => directory,
        :corl_file => config.get(:corl_file, true)
      }), provider)

    else
      logger.info("Opening existing project at #{directory}")
    end

    @@projects[directory]
  end

  #-----------------------------------------------------------------------------
  # Project plugin interface

  def normalize(reload)
    super

    directory = Util::Disk.filename(get(:directory, Dir.pwd))

    set_directory(directory)
    register

    set_url(get(:url)) if get(:url, false)

    myself.plugin_name = path if ! plugin_name || plugin_name.to_sym == plugin_provider

    ui.resource = plugin_name
    logger      = plugin_name

    if keys = delete(:keys, nil)
      set(:private_key, keys[:private_key])
      set(:public_key, keys[:public_key])
    end

    extension(:normalize)

    init_project
    extension(:init)

    pull if get(:pull, false)

    unless reload
      @cache = Util::Cache.new(directory, Nucleon.sha1(plugin_name), '.project_cache')
      init_cache

      if get(:corl_file, true) && ! self.class.load_provider(directory)
        self.class.store_provider(directory, plugin_provider)
      end
    end
  end

  #---

  def init_project
    init_auth
    init_parent
    init_remotes
    load_revision
  end

  #-----------------------------------------------------------------------------
  # Plugin operations

  def register
    super
    if directory
      lib_path = File.join(directory, 'lib')
      if File.directory?(lib_path)
        Nucleon.register(lib_path)
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Checks

  def can_persist?
    return top?(directory) if directory
    false
  end

  #---

  def top?(path)
    return true if File.directory?(path)
    false
  end

  #---

  def subproject?(path)
    false
  end

  #---

  def project_directory?(path, require_top_level = false)
    path = File.expand_path(path)
    return true if File.directory?(path) && (! require_top_level || top?(path))
    false
  end
  protected :project_directory?

  #---

  def manage_ignore=ignore
    set(:manage_ignore, ignore)
  end

  def manage_ignore?
    get(:manage_ignore, false)
  end

  #-----------------------------------------------------------------------------
  # Property accessor / modifiers

  def cache
    @cache
  end

  #---

  def reference
    get(:reference, nil)
  end

  #---

  def private_key
    get(:private_key, nil)
  end

  def private_key_str
    return Util::Disk.read(private_key) if private_key
    nil
  end

  def public_key
    get(:public_key, nil)
  end

  def public_key_str
    return Util::Disk.read(public_key) if public_key
    nil
  end

  #---

  def url(default = nil)
    get(:url, default)
  end

  #---

  def set_url(url)
    if url && url = extension_set(:set_url, url.strip)
      logger.info("Setting project #{name} url to #{url}")

      set(:url, url)
      set_remote(:origin, url)
    end
  end

  #---

  def edit_url(default = nil)
    get(:edit, default)
  end

  #---

  def set_edit_url(url)
    url = url.strip
    if url && url = extension_set(:set_edit_url, url)
      logger.info("Setting project #{name} edit url to #{url}")

      set(:edit, url)
      set_remote(:edit, url)
    end
  end

  #---

  def directory(default = nil)
    get(:directory, default)
  end

  #---

  def path
    if parent.nil?
      return directory
    end
    directory.gsub(parent.directory + File::SEPARATOR, '')
  end

  #---

  def set_directory(directory)
    if Util::Data.empty?(directory)
      current_directory = Dir.pwd
    else
      current_directory = File.expand_path(Util::Disk.filename(directory))
    end

    if current_directory = extension_set(:set_directory, current_directory)
      logger.info("Setting project #{name} directory to #{current_directory}")

      @@projects.delete(get(:directory)) if get(:directory)
      @@projects[current_directory] = myself

      set(:directory, current_directory)
    end
  end
  protected :set_directory

  #---

  def set_location(directory)
    set_directory(directory)

    yield if block_given?

    init_project
  end

  #---

  def parent(default = nil)
    get(:parent, default)
  end

  #---

  def subprojects(default = nil)
    get(:subprojects, default)
  end

  #---

  def revision(default = nil)
    get(:revision, default).to_s
  end

  #---

  def config(name, options = {})
    localize do
      config = Config.ensure(options)
      can_persist? && block_given? ? yield(config) : nil
    end
  end

  #---

  def set_config(name, value, options = {})
    localize do
      config = Config.ensure(options)

      if can_persist? && value = extension_set(:set_config, value, { :name => name, :config => config })
        logger.info("Setting project #{self.name} configuration: #{name} = #{value.inspect}")

        yield(config, value) if block_given?
      end
    end
  end

  #---

  def delete_config(name, options = {})
    localize do
      config = Config.ensure(options)

      if can_persist? && extension_check(:delete_config, { :name => name, :config => config })
        logger.info("Removing project #{self.name} configuration: #{name}")

        yield(config) if block_given?
      end
    end
  end

  #---

  def subproject_config(options = {})
    result = {}

    localize do
      if can_persist?
        config = Config.ensure(options)
        result = yield(config) if block_given?

        extension(:subproject_config, { :config => result })

        logger.debug("Subproject configuration: #{result.inspect}")
      end
    end
    result
  end
  protected :subproject_config

  #-----------------------------------------------------------------------------
  # Project operations

  def init_cache
    ignore(self.class.state_file)
  end
  protected :init_cache

  #---

  def init_auth
    if can_persist?
      localize do
        logger.info("Initializing project #{name} authorization")
        yield if block_given?
      end
    else
      logger.warn("Project #{name} does not meet the criteria for persistence can not be authorized")
    end
  end
  protected :init_auth

  #---

  def init_parent
    delete(:parent)

    logger.info("Initializing project #{name} parents")

    if top?(directory)
      logger.debug("Project #{name} has no parents to initialize")
    else
      search_dir = directory
      last_dir   = nil

      while File.directory?((search_dir = File.expand_path('..', search_dir)))
        logger.debug("Scanning directory #{search_dir} for parent project")

        unless last_dir.nil? || last_dir != search_dir
          break
        end
        if project_directory?(search_dir)
          logger.debug("Directory #{search_dir} is a valid parent for this #{plugin_provider} project")

          project = myself.class.open(search_dir, plugin_provider)

          extension(:init_parent, { :parent => project })

          set(:parent, project)
          logger.debug("Setting parent to #{parent.inspect}")
          break;
        end
        last_dir = search_dir
      end
    end
  end
  protected :init_parent

  #---

  def load_revision
    if can_persist?
      localize do
        logger.info("Loading project #{plugin_name} revision")

        specified_revision = get(:revision, nil)

        current_revision = revision.to_s
        current_revision = yield if block_given?

        if current_revision && extended_revision = extension_set(:load_revision, specified_revision).to_s.strip
          if extended_revision.empty?
            extended_revision = current_revision
          end

          set(:revision, extended_revision)
          checkout(extended_revision) if current_revision != extended_revision

          logger.debug("Loaded revision: #{revision}")

          load_subprojects
        end
      end
    else
      logger.warn("Project #{name} does not meet the criteria for persistence and has no revision")
    end
  end
  protected :load_revision

  #---

  def checkout(revision)
    success = false

    if can_persist?
      localize do
        if extension_check(:checkout, { :revision => revision })
          logger.info("Checking out project #{name} revision: #{revision}")

          success = true
          success = yield(success) if block_given?

          if success
            set(:revision, revision)

            extension(:checkout_success, { :revision => revision })
            load_subprojects
          end
        end
      end
    else
      logger.warn("Project #{name} does not meet the criteria for persistence and can not checkout a revision")
    end
    success
  end

  #---

  def commit(files = '.', options = {})
    success = false

    if can_persist?
      localize do
        config = Config.ensure(options)

        if extension_check(:commit, { :files => files, :config => config })
          logger.info("Committing changes to project #{name}: #{files.inspect}")

          time     = Time.new.strftime("%Y-%m-%d %H:%M:%S")
          user     = config.delete(:user, ENV['USER'] + '@' + fact(:fqdn))

          message  = config.get(:message, '')
          message  = 'Saving state: ' + ( files.is_a?(Array) ? "\n\n" + files.join("\n") : files.to_s ) if message.empty?

          user = 'UNKNOWN' unless user && ! user.empty?

          logger.debug("Commit by #{user} at #{time} with #{message}")
          success = yield(config, time, user, message) if block_given?

          if success
            load_revision

            extension(:commit_success, { :files => files })

            if ! parent.nil? && config.get(:propogate, true)
              logger.info("Commit to parent as parent exists and propogate option given")

              parent.load_revision
              parent.commit(directory, config.import({
                :message => "Updating #{path}: #{message}"
              }))
            end
          end
        end
      end
    else
      logger.warn("Project #{name} does not meet the criteria for persistence and can not be committed to")
    end
    success
  end

  #---

  def ignore(files)
    return unless directory && manage_ignore?

    files = nil
    files = yield if block_given?
    commit(files, { :message => "Adding project ignores." }) if files
  end

  #-----------------------------------------------------------------------------
  # Subproject operations

  def load_subprojects(options = {})
    subprojects = {}

    if can_persist?
      config = Config.ensure(options)

      logger.info("Loading sub projects for project #{name}")

      subproject_config(config).each do |path, data|
        project_path = File.join(directory, path)

        if File.directory?(project_path)
          logger.debug("Checking if project path #{project_path} is a valid sub project")

          add_project = true
          add_project = yield(project_path, data) if block_given?

          if add_project
            logger.debug("Directory #{project_path} is a valid sub project for this #{plugin_provider} project")

            project = myself.class.open(project_path, plugin_provider, { :corl_file => get(:corl_file, true) })

            extension(:load_project, { :project => project })
            subprojects[path] = project
          else
            logger.warn("Directory #{project_path} is not a valid sub project for this #{plugin_provider} project")
          end
        else
          logger.warn("Sub project configuration points to a location that is not a directory: #{project_path}")
        end
      end
    else
      logger.warn("Project #{name} does not meet the criteria for persistence and can not have sub projects")
    end
    set(:subprojects, subprojects)
  end
  protected :load_subprojects

  #---

  def add_subproject(path, url, revision, options = {})
    success = true

    if can_persist?
      localize do
        config = Config.ensure(options).import({ :path => path, :url => url, :revision => revision })

        if extension_check(:add_project, { :config => config })
          logger.info("Adding a sub project to #{config[:path]} from #{config[:url]} at #{config[:revision]}")

          success = yield(config) if block_given?

          if success
            extension(:add_project_success, { :config => config })

            config.init(:files, '.')
            config.init(:message, "Adding project #{config[:url]} to #{config[:path]}")

            commit(config[:files], { :message => config[:message] })
            update_subprojects
          end
        else
          success = false
        end
      end
    else
      logger.warn("Project #{name} does not meet the criteria for persistence and can not have sub projects")
    end
    success
  end

  #---

  def delete_subproject(path)
    success = true

    if can_persist?
      localize do
        config = Config.new({ :path => path })

        if extension_check(:delete_project, { :config => config })
          logger.info("Deleting a sub project at #{config[:path]}")

          success = yield(config) if block_given?

          if success
            extension(:delete_project_success, { :config => config })

            config.init(:files, '.')
            config.init(:message, "Removing project at #{config[:path]}")

            commit(config[:files], { :message => config[:message] })
            update_subprojects
          end
        end
      end
    else
      logger.warn("Project #{name} does not meet the criteria for persistence and can not have sub projects")
    end
    success
  end

  #---

  def update_subprojects(options = {})
    if can_persist?
      localize do
        config = Config.ensure(options)

        if extension_check(:update_projects)
          logger.info("Updating sub projects in project #{name}")

          success = false
          success = yield(config) if block_given?

          if success
            extension(:update_projects_success)
            load_subprojects
          end
        end
      end
    else
      logger.warn("Project #{name} does not meet the criteria for persistence and can not have sub projects")
    end
  end
  protected :update_subprojects

  #---

  def each
    if can_persist?
      localize do
        logger.info("Iterating through all sub projects of project #{name}")

        subprojects.each do |path, project|
          extension(:process_project, { :project => project })

          logger.debug("Running process on sub project #{path}")
          yield(path, project)
        end
      end
    else
      logger.warn("Project #{name} does not meet the criteria for persistence and can not have sub projects")
    end
  end

  #-----------------------------------------------------------------------------
  # Remote operations

  def init_remotes
    if can_persist?
      localize do
        logger.info("Initializing project #{name} remotes")

        origin_url = url
        origin_url = yield if block_given?

        if origin_url && origin_url = extension_set(:init_remotes, origin_url).to_s.strip
          set(:url, origin_url)
          set_edit_url(translate_edit_url(url))
        end
      end
    else
      logger.warn("Project #{name} does not meet the criteria for persistence and can not have remotes")
    end
  end
  protected :init_remotes

  #---

  def remote(name)
    url = nil
    if can_persist?
      localize do
        logger.info("Fetching remote url for #{name}")
        url = yield if block_given?
      end
    end
    url
  end

  #---

  def set_remote(name, url, options = {})
    config = Config.ensure(options)

    if can_persist?
      localize do
        unless url.strip.empty?
          if url = extension_set(:set_remote, url, { :name => name })
            delete_remote(name)

            url = translate_edit_url(url) if name == :edit && config.get(:translate, true)

            logger.info("Setting project remote #{name} to #{url}")
            yield(url) if block_given?
          end
        end
      end
    else
      logger.warn("Project #{self.name} does not meet the criteria for persistence and can not have remotes")
    end
  end

  #---

  def add_remote_url(name, url, options = {})
    if can_persist?
      localize do
        config = Config.ensure(options)

        if url = extension_set(:add_remote_url, url, { :name => name, :config => config })
          url = translate_edit_url(url) if name == :edit && config.get(:translate, true)

          logger.info("Adding project remote url #{url} to #{name}")
          yield(config, url) if block_given?
        end
      end
    else
      logger.warn("Project #{self.name} does not meet the criteria for persistence and can not have remotes")
    end
  end

  #---

  def set_host_remote(name, hosts, path, options = {})
    if can_persist?
      localize do
        config = Config.ensure(options).import({ :path => path, :translate => false })
        hosts  = array(hosts)

        unless hosts.empty?
          if hosts = extension_set(:set_host_remote, hosts, { :name => name, :config => config })
            unless ! hosts || hosts.empty?
              path = config.delete(:path)

              logger.info("Setting host remote #{name} for #{hosts.inspect} at #{path}")
              set_remote(name, translate_url(hosts.shift, path, config.export), config)

              hosts.each do |host|
                logger.debug("Adding remote url to #{host}")
                add_remote_url(name, translate_url(host, path, config.export), config)
              end
            end
          end
        end
      end
    else
      logger.warn("Project #{self.name} does not meet the criteria for persistence and can not have remotes")
    end
  end

  #---

  def delete_remote(name)
    if can_persist?
      localize do
        if extension_check(:delete_remote, { :name => name })
          logger.info("Deleting project remote #{name}")
          yield if block_given?
        end
      end
    else
      logger.warn("Project #{self.name} does not meet the criteria for persistence and can not have remotes")
    end
  end

  #-----------------------------------------------------------------------------
  # Remote operations

  def pull(remote = :origin, options = {})
    config = Config.ensure(options)

    config[:remote] = remote(:edit) && remote == :origin ? :edit : remote

    success = false

    if can_persist?
      localize do
        if extension_check(:pull, { :directory => directory, :config => config })
          remote = config.delete(:remote)

          if remote(remote)
            logger.info("Pulling from #{remote} into #{directory}")
            success = yield(config, remote) if block_given?
          end

          if success
            update_subprojects

            extension(:pull_success, { :directory => directory, :remote => remote, :config => config })

            if ! parent.nil? && config.get(:propogate, true)
              logger.debug("Commit to parent as parent exists and propogate option was given")

              parent.commit(directory, config.import({
                :message     => "Pulling updates for subproject #{path}",
                :allow_empty => true
              }))
            end
          end
        end
      end
    else
      logger.warn("Project #{name} does not meet the criteria for persistence and can not pull from remotes")
    end
    success
  end

  #---

  def push(remote = :edit, options = {})
    config  = Config.ensure(options).import({ :remote => remote })
    no_pull = config.delete(:no_pull, false)
    success = false

    push_project = lambda do |push_remote|
      logger.info("Pushing to #{push_remote} from #{directory}")
      success = yield(config, push_remote) if block_given? && ( no_pull || pull(push_remote, config) )
    end

    if can_persist?
      unless remote(remote)
        logger.warn("Project #{plugin_name} does not have the remote '#{remote}' defined")
        return true
      end
      localize do
        if extension_check(:push, { :directory => directory, :config => config })
          remote = config.delete(:remote)
          tries  = config.delete(:tries, 5)

          # TODO: Figure out a better way through specialized exception handling
          begin
            success = push_project.call(remote)
            raise unless success

          rescue
            tries -= 1
            retry if tries > 0
          end

          if success
            config.delete(:revision)

            extension(:push_success, { :directory => directory, :remote => remote, :config => config })

            if config.get(:propogate, true)
              unless parent.nil?
                propogate_up = config.get(:propogate_up, nil)

                if propogate_up.nil? || propogate_up
                  logger.debug("Commit to parent as parent exists and propogate option was given")
                  parent.push(remote, Config.new(config.export.dup).import({
                    :propogate_up   => true,
                    :propogate_down => false
                  }))
                end
              end

              logger.debug("Pushing sub projects")

              propogate_down = config.get(:propogate_down, nil)

              if propogate_down.nil? || propogate_down
                each do |path, project|
                  project.push(remote, Config.new(config.export.dup).import({
                    :propogate_up   => false,
                    :propogate_down => true
                  }))
                end
              end
            end
          end
        end
      end
    else
      logger.warn("Project #{plugin_name} does not meet the criteria for persistence and can not push to remotes")
    end
    success
  end

  #-----------------------------------------------------------------------------
  # State configurations

  def self.state_file
    '.corl'
  end

  #---

  @@project_data = {}

  def self.store_provider(directory, provider)
    if File.directory?(directory)
      @@project_data[directory] = {
        :provider => provider
      }
      json_data = Util::Data.to_json(@@project_data[directory], true)
      Util::Disk.write(File.join(directory, state_file), json_data)
    end
  end

  #---

  def self.clear_provider(directory)
    @@project_data.delete(directory)
  end

  #---

  def self.load_provider(directory, override = nil)
    @@project_data[directory] = {} unless @@project_data.has_key?(directory)

    if override.nil? && @@project_data[directory].empty?
      json_data                 = Util::Disk.read(File.join(directory, state_file))
      @@project_data[directory] = hash(Util::Data.parse_json(json_data)) if json_data
    end
    override.nil? ? symbol_map(@@project_data[directory])[:provider] : override
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def self.build_info(namespace, plugin_type, data)
    data = data.split(/\s*,\s*/) if data.is_a?(String)
    super(namespace, plugin_type, data)
  end

  #---

  def self.translate(data)
    options = super(data)

    case data
    when String
      options = { :url => data }
    when Hash
      options = data
    end

    if options.has_key?(:url)
      if matches = translate_reference(options[:url])
        options[:provider]  = matches[:provider]
        options[:reference] = matches[:reference]
        options[:url]       = matches[:url]
        options[:revision]  = matches[:revision] unless options.has_key?(:revision)

        logger.debug("Translating project options: #{options.inspect}")
      end
    end
    options
  end

  #---

  def self.translate_reference(reference, editable = false)
    # ex: github:::username/project[branch/revision]
    if reference && reference.match(/^\s*([a-zA-Z0-9_-]+):::([^\]\s]+)\s*(?:\[\s*([^\]\s]+)\s*\])?\s*$/)
      provider = $1
      url      = $2
      revision = $3

      logger.debug("Translating project reference: #{provider}  #{url}  #{revision}")

      if provider && Nucleon.loaded_plugins(:nucleon, :project).keys.include?(provider.to_sym)
        klass        = Nucleon.class_const([ :nucleon, :project, provider ])
        expanded_url = klass.send(:expand_url, url, editable) if klass.respond_to?(:expand_url)
      end
      expanded_url = url unless expanded_url

      info = {
        :provider  => provider,
        :reference => url,
        :url       => expanded_url,
        :revision  => revision
      }

      logger.debug("Project reference info: #{info.inspect}")
      return info
    end
    nil
  end

  #---

  def translate_reference(reference, editable = false)
    myself.class.translate_reference(reference, editable)
  end

  #---

  def translate_url(host, path, options = {})
    config = Config.ensure(options)
    url    = "#{host}/#{path}"

    if block_given?
      temp_url = yield(config)
      url      = temp_url if temp_url
    end
    url
  end

  #---

  def translate_edit_url(url, options = {})
    config = Config.ensure(options)

    if block_given?
      temp_url = yield(config)
      url      = temp_url if temp_url
    end
    url
  end

  #---

  def localize(path = nil)
    prev_directory = Dir.pwd
    path           = directory if path.nil?

    Dir.chdir(path)

    result = safe_exec(true) do
      yield
    end

    Dir.chdir(prev_directory)
    result
  end

  #---

  def local_path(file_path)
    file_path.gsub(directory + File::SEPARATOR, '')
  end

  #---

  def full_path(local_path)
    File.join(directory, local_path)
  end
end
end
end
