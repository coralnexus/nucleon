module Nucleon
#
# == Plugin manager
#
# The Nucleon::Manager class defines a manager for defined plugin types, loaded,
# metadata, and active instances.
#
# One of the primary functions of the Nucleon library is to provide a very
# flexible extensible architectural base for Ruby applications needing ready
# made modularity.  To fulfill our objectives, the Nucleon library defines
# plugin managers managed as a global multition.
#
# These managers should be able to fail gracefully and recover to the state
# they left off if a plugin provider crashes.  To accomplish this, each manager
# is a Celluloid actor that manages a globally defined environment (also within
# a multition).  This environment contains all of the plugins and providers
# that they manager has registered and loaded.
#
#
# See also:
# - Nucleon::Environment
# - Nucleon::Plugin::Base
#
class Manager

  #
  # Make instances of this class parallel capable (through Celluloid actors)
  #
  include Parallel

  #*****************************************************************************

  #
  # Global collection of plugin manager supervisors or managers.
  #
  # If parallel is enabled this will be supervisors, otherwise just the managers.
  #
  @@supervisors = {}

  #
  # Accessor for the global supervisors (mostly for testing purposes)
  #
  def self.supervisors
    @@supervisors
  end

  #
  # Global collection of plugin manager environments.
  #
  # Environments are keyed by an actor id set by the manager
  #
  @@environments = {}

  #
  # Accessor for the global plugin manager environments (mostly for testing purposes)
  #
  def self.environments
    @@environments
  end

  #*****************************************************************************
  # Plugin manager interface

  # Return a specified plugin manager instance
  #
  # * *Parameters*
  #   - [String, Symbol] *name*  Name of the plugin manager (actor id)
  #   - [Boolean] *reset*  Whether or not to reinitialize the manager
  #
  # * *Returns*
  #   - [Nucleon::Manager, Celluloid::Actor]  Returns an interface to manage plugins
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Facade#manager
  #
  def self.connection(name = :core, reset = false)
    Nucleon.manager(@@supervisors, name, self, reset)
  end

  # Initialize a new Nucleon environment
  #
  # IMORTANT:  The environment constructor should accept no parameters!
  #
  # * *Parameters*
  #   - [String, Symbol] *actor_id*  Name of the plugin manager
  #   - [Boolean] *reset*  Whether or not to reinitialize the manager
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Facade#logger
  # - Nucleon::Environment
  #
  def initialize(actor_id, reset)
    @logger   = Nucleon.logger
    @actor_id = actor_id.to_sym

    if reset || ! @@environments[@actor_id]
      @@environments[@actor_id] = Environment.new
    end
  end

  # Perform any cleanup operations during manager shutdown
  #
  # This only runs when in parallel mode.
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - #active_plugins
  # - #remove
  #
  def parallel_finalize
    active_plugins.each do |namespace, namespace_plugins|
      namespace_plugins.each do |plugin_type, type_plugins|
        type_plugins.each do |instance_name, plugin|
          remove(plugin)
        end
      end
    end
  end

  #
  # [Nucleon::Util::Logger]  Instance logger
  #
  attr_reader :logger

  #
  # [Symbol]  Plugin manager identifier
  #
  attr_reader :actor_id

  # Return a reference to self
  #
  # This is needed so we can wrap instances in Celluloid actor proxies.
  # Using self directly causes a lot of headaches.
  #
  # https://github.com/celluloid/celluloid/wiki/Gotchas#never-return-self-or-pass-self-as-an-argument-to-other-actors
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Nucleon::Manager, Celluloid::Actor]  Returns a reference to this manager instance
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Facade#handle
  #
  def myself
    Nucleon.handle(self)
  end

  # Return true as a test method for checking for running manager
  #
  # This method should always return true and is only really called internally
  # to perform a system check when running in parallel mode.
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Nucleon::Manager, Celluloid::Actor]  Returns a reference to this manager instance
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Facade#manager
  # - Nucleon::Facade#test_connection
  #
  def test_connection
    true
  end

  #*****************************************************************************
  # Plugin model accessors / modifiers

  # Return all of the defined namespaces in the plugin environment.
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Array<Symbol>]  Array of defined plugin namespaces
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Environment#namespaces
  #
  def namespaces
    @@environments[@actor_id].namespaces
  end

  # Return all of the defined plugin types in a plugin namespace.
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #
  # * *Returns*
  #   - [Array<Symbol>]  Array of defined plugin types
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Environment#plugin_types
  #
  def types(namespace)
    @@environments[@actor_id].plugin_types(namespace)
  end

  # Define a new plugin type in a specified namespace.
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #   - [String, Symbol] *plugin_type*  Plugin type name within namespace
  #   - [String, Symbol] *default_provider*  Default provider
  #
  # * *Returns*
  #   - [Nucleon::Manager, Celluloid::Actor]  Returns reference to self for compound operations
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Environment#define_plugin_type
  #
  def define_type(namespace, plugin_type, default_provider)
    @@environments[@actor_id].define_plugin_type(namespace, plugin_type, default_provider)
    myself
  end

  # Define one or more new plugin types in a specified namespace.
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #   - [Hash<String, Symbol|String, Symbol>] *type_info*  Plugin type, default provider pairs
  #
  # * *Returns*
  #   - [Nucleon::Manager, Celluloid::Actor]  Returns reference to self for compound operations
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Environment#define_plugin_types
  #
  def define_types(namespace, type_info)
    @@environments[@actor_id].define_plugin_types(namespace, type_info)
  end

  # Check if a specified plugin type has been defined
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #   - [String, Symbol] *plugin_type*  Plugin type name to check within namespace
  #
  # * *Returns*
  #   - [Boolean]  Returns true if plugin type exists, false otherwise
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Environment#plugin_type_defined
  #
  def type_defined?(namespace, plugin_type)
    @@environments[@actor_id].plugin_type_defined?(namespace, plugin_type)
  end

  # Return the default provider currently registered for a plugin type
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #   - [String, Symbol] *plugin_type*  Plugin type name to fetch default provider
  #
  # * *Returns*
  #   - [nil, Symbol]  Returns default provider if plugin type exists, nil otherwise
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Environment#plugin_type_default
  #
  def type_default(namespace, plugin_type)
    @@environments[@actor_id].plugin_type_default(namespace, plugin_type)
  end

  # Return the load information for a specified plugin provider if it exists
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #   - [String, Symbol] *plugin_type*  Plugin type name of provider
  #   - [String, Symbol] *provider*  Plugin provider to return load information
  #
  # * *Returns*
  #   - [nil, Hash<Symbol|ANY>]  Returns provider load information if provider exists, nil otherwise
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Environment#loaded_plugin
  #
  def loaded_plugin(namespace, plugin_type, provider)
    @@environments[@actor_id].loaded_plugin(namespace, plugin_type, provider)
  end

  # Return the load information for namespaces, plugin types, providers if it exists
  #
  # * *Parameters*
  #   - [nil, String, Symbol] *namespace*  Namespace to return load information
  #   - [nil, String, Symbol] *plugin_type*  Plugin type name to return load information
  #   - [nil, String, Symbol] *provider*  Plugin provider to return load information
  #
  # * *Returns*
  #   - [nil, Hash<Symbol|Symbol|Symbol|Symbol|ANY>]  Returns all load information if no parameters given
  #   - [nil, Hash<Symbol|Symbol|Symbol|ANY>]  Returns namespace load information if only namespace given
  #   - [nil, Hash<Symbol|Symbol|ANY>]  Returns plugin type load information if namespace and plugin type given
  #   - [nil, Hash<Symbol|ANY>]  Returns provider load information if namespace, plugin type, and provider given
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Environment#loaded_plugins
  #
  def loaded_plugins(namespace = nil, plugin_type = nil, provider = nil)
    @@environments[@actor_id].loaded_plugins(namespace, plugin_type, provider)
  end

  # Define a new plugin provider of a specified plugin type.
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #   - [String, Symbol] *plugin_type*  Plugin type name to fetch default provider
  #   - [String] *base_path*  Base load path of the plugin provider
  #   - [String] *file*  File that contains the provider definition
  #
  # * *Returns*
  #   - [Nucleon::Manager, Celluloid::Actor]  Returns reference to self for compound operations
  #
  # * *Errors*
  #
  # * *Yields*
  #   - [Hash<Symbol|ANY>] *data*  Plugin load information
  #
  # See:
  # - Nucleon::Environment#define_plugin
  #
  #
  def define_plugin(namespace, plugin_type, base_path, file, &code) # :yields: data
    @@environments[@actor_id].define_plugin(namespace, plugin_type, base_path, file, &code)
    myself
  end

  # Check if a specified plugin provider has been loaded
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #   - [String, Symbol] *plugin_type*  Plugin type name to check
  #   - [String, Symbol] *provider*  Plugin provider name to check
  #
  # * *Returns*
  #   - [Boolean]  Returns true if plugin provider has been loaded, false otherwise
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Environment#plugin_has_provider?
  #
  def plugin_has_provider?(namespace, plugin_type, provider)
    @@environments[@actor_id].plugin_has_provider?(namespace, plugin_type, provider)
  end

  # Return active plugins for namespaces, plugin types, providers if specified
  #
  # * *Parameters*
  #   - [nil, String, Symbol] *namespace*  Namespace to return plugin instance
  #   - [nil, String, Symbol] *plugin_type*  Plugin type name to return plugin instance
  #   - [nil, String, Symbol] *provider*  Plugin provider to return plugin instance
  #
  # * *Returns*
  #   - [nil, Hash<Symbol|Symbol|Symbol|Symbol|Nucleon::Plugin::Base>]  Returns all plugin instances if no parameters given
  #   - [nil, Hash<Symbol|Symbol|Symbol|Nucleon::Plugin::Base>]  Returns namespace plugin instances if only namespace given
  #   - [nil, Hash<Symbol|Symbol|Nucleon::Plugin::Base>]  Returns plugin type instances if namespace and plugin type given
  #   - [nil, Hash<Symbol|Nucleon::Plugin::Base>]  Returns provider instances if namespace, plugin type, and provider given
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Plugin::Base
  # - Nucleon::Environment#active_plugins
  #
  def active_plugins(namespace = nil, plugin_type = nil, provider = nil)
    @@environments[@actor_id].active_plugins(namespace, plugin_type, provider)
  end

  #*****************************************************************************
  # Plugin registration / initialization

  def reload(core = false, loaded = [], &code)
    logger.info("Loading Nucleon plugins at #{Time.now}")

    if core
      Celluloid.logger = logger if Nucleon.parallel?

      define_types :nucleon, {
        :extension  => nil,             # Core
        :action     => :project_update, # Core
        :project    => :git,            # Core
        :command    => :bash,           # Core
        :event      => :regex,          # Utility
        :template   => :json,           # Utility
        :translator => :json            # Utility
      }
    end

    # Allow block level namespace and type registration
    code.call(:define, myself) if code

    load_plugins(core, loaded, &code)
    logger.info("Finished loading Nucleon plugins at #{Time.now}")
  end

  def load_plugins(core = false, loaded = [], &code)
    if core
      # Register core plugins
      logger.info("Initializing core plugins at #{Time.now}")
      register(File.join(File.dirname(__FILE__), '..'))
    end

    # Register external Gem defined plugins
    Gems.register(true, Util::Data.array(loaded))

    # Register any other extension plugins
    exec(:register_plugins)

    # Catch any block level requests before autoloading
    code.call(:load, myself) if code

    # Autoload all registered plugins
    autoload
  end
  protected :load_plugins

  def register(base_path, &code)
    namespaces.each do |namespace|
      namespace_path = File.join(base_path, namespace.to_s)
      register_namespace(namespace, namespace_path, &code)
    end
  end

  def register_namespace(namespace, base_path, &code)
    if File.directory?(base_path)
      logger.info("Loading files from #{base_path} at #{Time.now}")

      Dir.glob(File.join(base_path, '*.rb')).each do |file|
        logger.debug("Loading file: #{file}")
        require file
      end

      logger.info("Loading directories from #{base_path} at #{Time.now}")
      Dir.entries(base_path).each do |path|
        unless path.match(/^\.\.?$/)
          register_type(namespace, base_path, path, &code) if type_defined?(namespace, path)
        end
      end
    end
  end
  protected :register_namespace

  def register_type(namespace, base_path, plugin_type, &code)
    base_directory = File.join(base_path, plugin_type.to_s)

    if File.directory?(base_directory)
      logger.info("Registering #{base_directory} at #{Time.now}")

      Dir.glob(File.join(base_directory, '**', '*.rb')).each do |file|
        define_plugin(namespace, plugin_type, base_directory, file, &code)
      end
    end
  end
  protected :register_type

  # Autoload all of the defined plugins
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Environment#autoload
  #
  # See also:
  # - #load
  #
  def autoload
    logger.info("Autoloading registered plugins at #{Time.now}")

    @@environments[@actor_id].autoload do |namespace, plugin_type, provider, plugin|
      logger.debug("Autoloading provider #{provider} at #{plugin[:directory]}")

      # Make sure extensions are listening from the time they are loaded
      if plugin[:namespace] == :nucleon && plugin_type == :extension
        logger.debug("Creating #{plugin_type} #{provider}")

        # Create a persistent instance
        load(plugin[:namespace], :extension, provider, { :name => provider })
      end
    end
  end


  #*****************************************************************************
  # Plugin workflow

  def load_base(namespace, plugin_type, provider, options = {})
    logger.info("Fetching plugin #{namespace} #{plugin_type} provider #{provider} at #{Time.now}")

    type_info  = loaded_plugin(namespace, plugin_type, provider)
    options    = translate_type(type_info, options)
    config     = Config.ensure(options)
    name       = config.get(:name, nil)
    ensure_new = config.get(:new, false)

    if name
      logger.debug("Looking up existing instance of #{name}")

      if existing_instance = get(namespace, plugin_type, name)
        unless ensure_new
          config.delete(:new)

          config.export.each do |property_name, value|
            unless [ :name, :meta ].include?(property_name)
              existing_instance[property_name] = value
            end
          end
          existing_instance.normalize(true)

          logger.debug("Using existing instance of #{plugin_type}, #{name}")
          return existing_instance
        end
      end
    end
    create(namespace, plugin_type, provider, config)
  end

  def load(namespace, plugin_type, provider = nil, options = {})
    default_provider = type_default(namespace, plugin_type)

    # Allow options to override provider
    config   = Config.ensure(options)
    provider = config.delete(:provider, provider)
    provider = default_provider unless provider

    provider = value(:manager_plugin_provider, provider, Util::Data.merge([ config.export, {
      :namespace => namespace,
      :type      => plugin_type
    }]))

    load_base(namespace, plugin_type, provider, config)
  end

  def load_multiple(namespace, plugin_type, data, build_hash = false, keep_array = false)
    logger.info("Fetching multiple plugins of #{plugin_type} at #{Time.now}")

    group = ( build_hash ? {} : [] )
    klass = plugin_class(namespace, plugin_type)
    data  = klass.build_info(namespace, plugin_type, data) if klass.respond_to?(:build_info)

    data.each do |options|
      if plugin = load(namespace, plugin_type, options[:provider], options)
        if build_hash
          group[plugin.plugin_name] = plugin
        else
          group << plugin
        end
      end
    end
    return group.shift if ! build_hash && group.length == 1 && ! keep_array
    group
  end

  def create(namespace, plugin_type, provider, options = {})
    @@environments[@actor_id].create_plugin(namespace, plugin_type, provider, options) do |type_info, plugin_options|
      logger.info("Creating new plugin #{provider} #{plugin_type}")
      translate(type_info, plugin_options)
    end
  end

  # Return a plugin instance by name if it exists
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains the plugin
  #   - [String, Symbol] *plugin_type*  Plugin type name
  #   - [String, Symbol] *plugin_name*  Plugin name to return
  #
  # * *Returns*
  #   - [nil, Nucleon::Plugin::Base]  Returns a plugin instance of name specified if it exists
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Plugin::Base
  # - Nucleon::Environment#get_plugin
  #
  def get(namespace, plugin_type, plugin_name)
    @@environments[@actor_id].get_plugin(namespace, plugin_type, plugin_name)
  end

  def remove_by_name(namespace, plugin_type, plugin_instance_name)
    active_instances = active_plugins(namespace, plugin_type)

    if active_instances.has_key?(plugin_instance_name)
      @@environments[@actor_id].remove_plugin(namespace, plugin_type, plugin_instance_name) do |plugin|
        logger.debug("Removing #{plugin_type} #{plugin_instance_name}")

        if plugin.respond_to?(:terminate) # For Celluloid plugins
          plugin.terminate
        else
          plugin.remove_plugin
        end
      end
    end
  end

  def remove(plugin)
    begin # TODO: Figure out what do do about the plugin proxy being terminated before respond_to? method called.
      if plugin && plugin.respond_to?(:plugin_type)
        remove_by_name(plugin.plugin_namespace, plugin.plugin_type, plugin.plugin_instance_name)
      end
    rescue
    end
  end

  #*****************************************************************************
  # Extension hook execution

  def exec(method, options = {})
    results = nil

    logger.info("Executing extension hook #{Nucleon.blue(method)} at #{Nucleon.green(Time.now.to_s)}")

    extensions = active_plugins(:nucleon, :extension)

    extensions.each do |name, plugin|
      provider = plugin.plugin_provider
      result   = nil

      logger.debug("Checking extension #{provider}")

      if plugin.respond_to?(method)
        results = {} if results.nil?

        result = plugin.send(method, options)
        logger.info("Completed hook #{method} at #{Time.now}")

        if block_given?
          results[provider] = yield(:process, result)
          logger.debug("Processed extension result into: #{results[provider].inspect}")
        end

        if results[provider].nil?
          logger.debug("Setting extension result to: #{result.inspect}")
          results[provider] = result
        end
      end
    end

    if ! results.nil? && block_given?
      results = yield(:reduce, results)
      logger.debug("Reducing extension results to: #{results.inspect}")
    else
      logger.debug("Final extension results: #{results.inspect}")
    end
    results
  end

  def config(type, options = {})
    config = Config.ensure(options)

    logger.debug("Generating #{type} extended configuration")

    exec("#{type}_config", Config.new(config.export)) do |op, data|
      if op == :reduce
        data.each do |provider, result|
          config.import(result)
        end
        nil
      else
        data
      end
    end
    config.delete(:extension_type)
    config
  end

  def check(method, options = {})
    config = Config.ensure(options)

    logger.debug("Checking extension #{method}")

    success = exec(method, config.import({ :extension_type => :check })) do |op, data|
      if op == :reduce
        ! data.values.include?(false)
      else
        data ? true : false
      end
    end

    success = success.nil? || success ? true : false

    logger.debug("Extension #{method} check result: #{success.inspect}")
    success
  end

  def value(method, value, options = {})
    config = Config.ensure(options)

    logger.debug("Setting extension #{method} value")

    exec(method, config.import({ :value => value, :extension_type => :value })) do |op, data|
      if op == :process
        value = data unless data.nil?
      end
    end

    logger.debug("Extension #{method} retrieved value: #{value.inspect}")
    value
  end

  def collect(method, options = {})
    config = Config.ensure(options)
    values = []

    logger.debug("Collecting extension #{method} values")

    exec(method, config.import({ :extension_type => :collect })) do |op, data|
      if op == :process
        values << data unless data.nil?
      end
    end
    values = values.flatten

    logger.debug("Extension #{method} collected values: #{values.inspect}")
    values
  end

  #*****************************************************************************
  # Utilities

  def translate_type(type_info, options)
    if type_info
      klass = plugin_class(type_info[:namespace], type_info[:type])
      logger.debug("Executing option translation for: #{klass.inspect}")

      options = klass.send(:translate, options) if klass.respond_to?(:translate)
    end
    options
  end

  def translate(type_info, options)
    if type_info
      klass = type_info[:class]

      logger.debug("Executing option translation for: #{klass.inspect}")

      options = klass.send(:translate, options) if klass.respond_to?(:translate)
    end
    options
  end

  # Return a fully formed class name as a string
  #
  # * *Parameters*
  #   - [String, Symbol, Array] *name*  Class name components
  #   - [String, Symbol] *separator*  Class component separator (default '::')
  #   - [Boolean] *want_array*  Whether or not to return array of final components or string version
  #
  # * *Returns*
  #   - [String]  Returns fully rendered class name as string unless want_array is true
  #   - [Array]  Returns array of final class components if want_array is true
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Environment#class_name
  #
  def class_name(name, separator = '::', want_array = false)
    @@environments[@actor_id].class_name(name, separator, want_array)
  end

  # Return a fully formed class name as a machine usable constant
  #
  # * *Parameters*
  #   - [String, Symbol, Array] *name*  Class name components
  #   - [String, Symbol] *separator*  Class component separator (default '::')
  #
  # * *Returns*
  #   - [Class Constant]  Returns class constant for fully formed class name of given components
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Environment#class_const
  #
  def class_const(name, separator = '::')
    @@environments[@actor_id].class_const(name, separator)
  end

  # Return a class constant representing a base plugin class generated from namespace and plugin_type.
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Plugin namespace to constantize
  #   - [String, Symbol] *plugin_type*  Plugin type to constantize
  #
  # * *Returns*
  #   - [String]  Returns a class constant representing the plugin namespace and type
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Environment#plugin_class
  #
  def plugin_class(namespace, plugin_type)
    @@environments[@actor_id].plugin_class(namespace, plugin_type)
  end
end
end
