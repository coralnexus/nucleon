module Nucleon
#
# == Plugin environment
#
# The Nucleon::Environment class defines a container for registered plugins and
# autoloaded providers.
#
# One of the primary functions of the Nucleon library is to provide a very
# flexible extensible architectural base for Ruby applications needing ready
# made modularity.  To fulfill our objectives, the Nucleon library defines
# plugin managers managed as a global multition.
#
# These managers should be able to fail gracefully and recover to the state
# they left off if a plugin provider crashes.  To acomplish this, each manager
# is a Celluloid actor that manages a globally defined environment (also within
# a multition).  This environment contains all of the plugins and providers
# that they manager has registered and loaded.
#
# Three collections are managed:
#
# 1. Defined plugin types
#
#    The environment maintains a collection of registered plugin types with a
#    default provider.  Default providers can easily be changed in runtime as
#    needs change.
#
# 2. Plugin load info
#
#    Whenever a plugin is defined and initialized by the manager a specification
#    is created and maintained that lets the manager know details about the
#    plugin, such as where the base plugin resides, namespace, type, etc...
#
# 3. Active plugins
#
#    The environment maintains a registry of all of the plugin instances across
#    the application.  These active plugins are accessed by the manager, usually
#    through the facade.  When we work with plugins in the application, we are
#    usually working with these instances.
#
#
# See also:
# - Nucleon::Manager
#
class Environment < Core

  #*****************************************************************************
  # Constructor / Destructor

  # Initialize a new Nucleon environment
  #
  # IMORTANT:  The environment constructor should accept no parameters!
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Manager
  #
  def initialize
    super({
      :plugin_types => {},
      :load_info    => {},
      :active_info  => {}
    }, {}, true, true, false)
  end

  #*****************************************************************************
  # Plugin type accessor / modifiers

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
  # - Nucleon::Config#get_hash
  #
  def namespaces
    get_hash(:plugin_types).keys
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
  # - Nucleon::Config#get_hash
  #
  def plugin_types(namespace)
    get_hash([ :plugin_types, namespace ]).keys
  end

  # Define a new plugin type in a specified namespace.
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #   - [String, Symbol] *plugin_type*  Plugin type name within namespace
  #   - [String, Symbol] *default_provider*  Default provider (defaults to none)
  #
  # * *Returns*
  #   - [Nucleon::Environment]  Returns reference to self for compound operations
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Config#set
  #
  # See also:
  # - #sanitize_id
  #
  def define_plugin_type(namespace, plugin_type, default_provider = nil)
    set([ :plugin_types, namespace, sanitize_id(plugin_type) ], default_provider)
  end

  # Define one or more new plugin types in a specified namespace.
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #   - [Hash<String, Symbol|String, Symbol>] *type_info*  Plugin type, default provider pairs
  #
  # * *Returns*
  #   - [Nucleon::Environment]  Returns reference to self for compound operations
  #
  # * *Errors*
  #
  # See:
  # - #define_plugin_type
  #
  def define_plugin_types(namespace, type_info)
    if type_info.is_a?(Hash)
      type_info.each do |plugin_type, default_provider|
        define_plugin_type(namespace, plugin_type, default_provider)
      end
    end
    self
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
  # - Nucleon::Config#get_hash
  #
  # See also:
  # - #sanitize_id
  #
  def plugin_type_defined?(namespace, plugin_type)
    get_hash([ :plugin_types, namespace ]).has_key?(sanitize_id(plugin_type))
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
  # - Nucleon::Config#get
  #
  # See also:
  # - #sanitize_id
  #
  def plugin_type_default(namespace, plugin_type)
    get([ :plugin_types, namespace, sanitize_id(plugin_type) ])
  end


  #*****************************************************************************
  # Loaded plugin accessor / modifiers

  # Define a new plugin provider of a specified plugin type.
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #   - [String, Symbol] *plugin_type*  Plugin type name to fetch default provider
  #   - [String] *base_path*  Base load path of the plugin provider
  #   - [String] *file*  File that contains the provider definition
  #
  # * *Returns*
  #   - [Nucleon::Environment]  Returns reference to self for compound operations
  #
  # * *Errors*
  #
  # * *Yields*
  #   - [Hash<Symbol|ANY>] *data*  Plugin load information
  #
  # See:
  # - Nucleon::Config#get_hash
  # - Nucleon::Config#set
  #
  # See also:
  # - #sanitize_id
  # - #parse_plugin_info
  #
  def define_plugin(namespace, plugin_type, base_path, file, &code) # :yields: data
    namespace   = namespace.to_sym
    plugin_type = sanitize_id(plugin_type)
    plugin_info = parse_plugin_info(namespace, plugin_type, base_path, file)

    unless get_hash([ :load_info, namespace, plugin_type ]).has_key?(plugin_info[:provider])
      data = {
        :namespace        => namespace,
        :type             => plugin_type,
        :base_path        => base_path,
        :file             => file,
        :provider         => plugin_info[:provider],
        :directory        => plugin_info[:directory],
        :class_components => plugin_info[:class_components]
      }
      code.call(data) if code

      set([ :load_info, namespace, plugin_type, plugin_info[:provider] ], data)
    end
    self
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
  # - Nucleon::Config#get
  #
  # See also:
  # - #sanitize_id
  #
  def loaded_plugin(namespace, plugin_type, provider)
    get([ :load_info, namespace, sanitize_id(plugin_type), sanitize_id(provider) ], nil)
  end

  # Return the load information for namespaces, plugin types, providers if it exists
  #
  # * *Parameters*
  #   - [nil, String, Symbol] *namespace*  Namespace to return load information
  #   - [nil, String, Symbol] *plugin_type*  Plugin type name to return load information
  #   - [nil, String, Symbol] *provider*  Plugin provider to return load information
  #   - [ANY] *default*  Default results if nothing found (empty hash by default)
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
  # - Nucleon::Config#get_hash
  #
  # See also:
  # - #sanitize_id
  #
  def loaded_plugins(namespace = nil, plugin_type = nil, provider = nil, default = {})
    load_info   = get_hash(:load_info)

    namespace   = namespace.to_sym if namespace
    plugin_type = sanitize_id(plugin_type) if plugin_type
    provider    = sanitize_id(provider) if provider
    results     = default

    if namespace && load_info.has_key?(namespace)
      if plugin_type && load_info[namespace].has_key?(plugin_type)
        if provider && load_info[namespace][plugin_type].has_key?(provider)
          results = load_info[namespace][plugin_type][provider]
        elsif ! provider
          results = load_info[namespace][plugin_type]
        end
      elsif ! plugin_type
        results = load_info[namespace]
      end
    elsif ! namespace
      results = load_info
    end
    results
  end

  # Check if a specified plugin type has been loaded
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #   - [String, Symbol] *plugin_type*  Plugin type name to check
  #
  # * *Returns*
  #   - [Boolean]  Returns true if plugin type has been loaded, false otherwise
  #
  # * *Errors*
  #
  # See:
  # - Nucleon::Config#get_hash
  #
  # See also:
  # - #sanitize_id
  #
  def plugin_has_type?(namespace, plugin_type)
    get_hash([ :load_info, namespace ]).has_key?(sanitize_id(plugin_type))
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
  # - Nucleon::Config#get_hash
  #
  # See also:
  # - #sanitize_id
  #
  def plugin_has_provider?(namespace, plugin_type, provider)
    get_hash([ :load_info, namespace, sanitize_id(plugin_type) ]).has_key?(sanitize_id(provider))
  end

  #*****************************************************************************
  # Active plugin accessor / modifiers

  # Create a new plugin instance of a specified provider
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #   - [String, Symbol] *plugin_type*  Plugin type name of provider
  #   - [String, Symbol] *provider*  Plugin provider to return load information
  #   - [Hash] *options*  Create options (plugin initialization configurations)
  #
  # * *Returns*
  #   - [nil, Nucleon::Plugin::Base]  Returns plugin instance (inherited from Nucleon::Plugin::Base)
  #
  # * *Errors*
  #
  # * *Yields*
  #   - [nil, Hash<Symbol|ANY>]  *type_info*  Provider load information if it has been loaded
  #   - [Hash] *options*  Create options (plugin initialization configurations)
  #
  # See:
  # - Nucleon::Plugin::Base
  # - Nucleon::Config#get
  # - Nucleon::Config#set
  #
  # See also:
  # - #sanitize_id
  # - #plugin_type_defined?
  # - #loaded_plugin
  # - Nucleon::Config
  # - Nucleon::Config::array
  # - Nucleon::Util::Data::subset
  # - Nucleon::Facade#sha1
  #
  def create_plugin(namespace, plugin_type, provider, options = {}, &code) # :yields: type_info, options
    namespace   = namespace.to_sym
    plugin_type = sanitize_id(plugin_type)
    provider    = sanitize_id(provider)
    plugin      = nil

    unless plugin_type_defined?(namespace, plugin_type)
      return plugin
    end

    if type_info = loaded_plugin(namespace, plugin_type, provider)
      ids             = array(type_info[:class].register_ids).flatten
      instance_config = Config.new(options)
      ensure_new      = instance_config.delete(:new, false)

      instance_options = Util::Data.subset(instance_config.export, ids, true)
      instance_name    = "#{provider}_" + Nucleon.sha1(instance_options)
      plugin           = get([ :active_info, namespace, plugin_type, instance_name ])

      if ensure_new || ! ( instance_name && plugin )
        type_info[:instance_name] = instance_name

        options = code.call(type_info, options) if code
        options.delete(:new)

        plugin = type_info[:class].new(namespace, plugin_type, provider, options)
        set([ :active_info, namespace, plugin_type, instance_name ], plugin)
      end
    end
    plugin
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
  # - Nucleon::Config#get_hash
  #
  # See also:
  # - #sanitize_id
  #
  def get_plugin(namespace, plugin_type, plugin_name)
    namespace   = namespace.to_sym
    plugin_type = sanitize_id(plugin_type)

    get_hash([ :active_info, namespace, plugin_type ]).each do |instance_name, plugin|
      if plugin.plugin_name.to_s == plugin_name.to_s
        return plugin
      end
    end
    nil
  end

  # Remove a plugin instance from the environment
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains the plugin
  #   - [String, Symbol] *plugin_type*  Plugin type name
  #   - [String, Symbol] *instance_name*  Plugin instance name to tremove
  #
  # * *Returns*
  #   - [nil, Nucleon::Plugin::Base]  Returns the plugin instance that was removed from environment
  #
  # * *Errors*
  #
  # * *Yields*
  #   - [Nucleon::Plugin::Base] *plugin*  Plugin object being removed (cleanup)
  #
  # See:
  # - Nucleon::Plugin::Base
  # - Nucleon::Config#delete
  #
  # See also:
  # - #sanitize_id
  #
  def remove_plugin(namespace, plugin_type, instance_name, &code) # :yields: plugin
    plugin = delete([ :active_info, namespace, sanitize_id(plugin_type), instance_name ])
    code.call(plugin) if code && plugin
    plugin
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
  # - Nucleon::Config#get_hash
  #
  # See also:
  # - #sanitize_id
  #
  def active_plugins(namespace = nil, plugin_type = nil, provider = nil)
    active_info = get_hash(:active_info)

    namespace   = namespace.to_sym if namespace
    plugin_type = sanitize_id(plugin_type) if plugin_type
    provider    = sanitize_id(provider) if provider
    results     = {}

    if namespace && active_info.has_key?(namespace)
      if plugin_type && active_info[namespace].has_key?(plugin_type)
        if provider && ! active_info[namespace][plugin_type].keys.empty?
          active_info[namespace][plugin_type].each do |instance_name, plugin|
            plugin                 = active_info[namespace][plugin_type][instance_name]
            results[instance_name] = plugin if plugin.plugin_provider == provider
          end
        elsif ! provider
          results = active_info[namespace][plugin_type]
        end
      elsif ! plugin_type
        results = active_info[namespace]
      end
    elsif ! namespace
      results = active_info
    end
    results
  end

  #*****************************************************************************
  # Utilities

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
  def class_name(name, separator = '::', want_array = false)
    components = []

    case name
    when String, Symbol
      components = name.to_s.split(separator)
    when Array
      components = name
    end

    components.collect! do |value|
      value    = value.to_s.strip
      value[0] = value.capitalize[0] if value =~ /^[a-z]/
      value
    end

    if want_array
      return components
    end
    components.join(separator)
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
  # See also:
  # - #class_name
  #
  def class_const(name, separator = '::')
    components = class_name(name, separator, TRUE)
    constant   = Object

    components.each do |component|
      constant = constant.const_defined?(component) ?
                  constant.const_get(component) :
                  constant.const_missing(component)
    end
    constant
  end

  # Sanitize an identifier for internal plugin environment use.
  #
  # * *Parameters*
  #   - [String, Symbol] *id_component*  Identifier to sanitize
  #
  # * *Returns*
  #   - [Symbol]  Returns a sanitized symbol representing the given id component
  #
  # * *Errors*
  #
  def sanitize_id(id_component)
    id_component.to_s.gsub(/([a-z0-9])(?:\-|\_)?([A-Z])/, '\1_\2').downcase.to_sym
  end
  protected :sanitize_id

  # Sanitize a class identifier for internal use.
  #
  # * *Parameters*
  #   - [String, Symbol] *class_component*  Class identifier to sanitize
  #
  # * *Returns*
  #   - [String]  Returns a sanitized string representing the given class component
  #
  # * *Errors*
  #
  def sanitize_class(class_component)
    class_component.to_s.split('_').collect {|elem| elem.slice(0,1).capitalize + elem.slice(1..-1) }.join('')
  end
  protected :sanitize_class

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
  # See also:
  # - #class_const
  # - #sanitize_class
  #
  def plugin_class(namespace, plugin_type)
    class_const([ sanitize_class(namespace), :plugin, sanitize_class(plugin_type) ])
  end

  # Parse plugin information for a specified namespace and plugin type.
  #
  # * *Parameters*
  #   - [String, Symbol] *namespace*  Namespace that contains plugin types
  #   - [String, Symbol] *plugin_type*  Plugin type name to fetch default provider
  #   - [String] *base_path*  Base load path of the plugin provider
  #   - [String] *file*  File that contains the provider definition
  #
  # * *Returns*
  #   - [Hash<Symbol|ANY>]  Returns a hash of the parsed plugin information
  #
  # * *Errors*
  #
  # See also:
  # - #sanitize_id
  # - #sanitize_class
  #
  def parse_plugin_info(namespace, plugin_type, base_path, file)
    dir_components   = base_path.split(File::SEPARATOR)
    file_components  = file.split(File::SEPARATOR)

    file_name        = file_components.pop.sub(/\.rb/, '')
    directory        = file_components.join(File::SEPARATOR)

    file_class       = sanitize_class(file_name)
    group_components = directory.sub(/^#{base_path}#{File::SEPARATOR}?/, '').split(File::SEPARATOR)

    class_components = [ sanitize_class(namespace), sanitize_class(plugin_type) ]

    if ! group_components.empty?
      group_name       = group_components.collect {|elem| elem.downcase  }.join('_')
      provider         = [ group_name, file_name ].join('_')

      group_components = group_components.collect {|elem| sanitize_class(elem) }
      class_components = [ class_components, group_components, file_class ].flatten
    else
      provider         = file_name
      class_components = [ class_components, file_class ].flatten
    end

    {
      :directory        => directory,
      :provider         => sanitize_id(provider),
      :class_components => class_components
    }
  end
  protected :parse_plugin_info
end
end
