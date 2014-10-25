module Nucleon
#
# == Base configuration object
#
# The Nucleon::Config class defines a tree data container that can easily be
# merged and persisted to different mediums.
#
# The configuration is at the core of the Nucleon framework.  The configuration
# allows us to store, lookup, and perform other operations (such as merge) on
# our class data by treating a subset of class properties as a tree based data
# structure.
#
# Four main goals with this object:
#
# 1. Centralized property trees for objects
# 2. Easy access and management of nested properties
# 3. Mergeable objects (deep or shallow merges of tree based data)
# 4. Provide basic data translation utilities to sub classes
#
# == Global interface
#
# The Nucleon::Config class uses two *static* mixins that provide a central
# registry for option groups and property collections.
#
# Option groups are contextualized collections of properties
#
# - see Nucleon::Config::Options (collection implementation)
# - see Nucleon::Mixin::ConfigOptions (embeddable method interface)
#
# Property collections are flexible groups of properties that can be logged
# to file system.
#
# - see Nucleon::Config::Collection (collection implementation)
# - see Nucleon::Mixin::ConfigCollection (embeddable method interface)
#
# == Instance generators
#
# The core configuration object provides a few instance generators that allow
# for easier initialization of configurations.
#
class Config

  #*****************************************************************************
  # Global interface

  # Include global contextual configuration option interface
  #
  # See:
  #  - Nucleon::Mixin::ConfigOptions
  #  - Nucleon::Config::Options
  #
  extend Mixin::ConfigOptions

  # Include global configuration log interface
  #
  # See:
  #  - Nucleon::Mixin::ConfigCollection
  #  - Nucleon::Config::Collection
  #
  extend Mixin::ConfigCollection

  #*****************************************************************************
  # Instance generators

  # Ensure the return of a Nucleon::Config object based on different inputs.
  #
  # This method can also initialize defaults for the configuration object if
  # the configurations do not exist yet.
  #
  # For example: (you will see variants of this pattern everywhere)
  #
  #   def some_method(options = {})
  #     # Options might be a Config object or Hash?
  #     config = Config.ensure(options, { :my_property => 'default value' })
  #     prop   = config[:my_property]
  #   end
  #
  # * *Parameters*
  #   - [nil, Hash, Nucleon::Config] *config*  Configurations to evaluate and possibly convert
  #   - [Hash] *defaults*  Configuration defaults that may be overridden by config data
  #   - [Boolean] *force*  Whether or not to force override of values where types don't match during merge
  #   - [Boolean] *basic_merge*  Whether or not to perform a basic merge or deep (recursive) merge
  #
  # * *Returns*
  #   - [Nucleon::Config]  Returns configuration object
  #
  # * *Errors*
  #
  # See:
  # - ::new
  # - #defaults
  #
  def self.ensure(config, defaults = {}, force = true, basic_merge = true)
    case config
    when Nucleon::Config
      return config.defaults(defaults, { :force => force, :basic => basic_merge })
    when Hash
      return new(config, defaults, force, basic_merge)
    end
    return new({}, defaults, force, basic_merge)
  end

  # Initialize a new configuration object with contextualized defaults from the
  # global configuration option collection.
  #
  # This method is not really used much within Nucleon itself, but is used to
  # help create the corl gem Puppet interface that forms the provisioner
  # configurations for resource creation based on options defined in Puppet.
  #
  # This method supports hierarchical lookup of context properties.
  #
  # Example:
  #
  #   Nucleon::Config::set_options([ :context1, :prefix_context2 ], { :my_property => 'value' })
  #
  #   config = Nucleon::Config.init({ :other_property => 'something' }, :context2, :prefix)
  #   config.export
  #   # {
  #   #   :my_property => 'value',
  #   #   :other_property => 'something'
  #   # }
  #
  # * *Parameters*
  #   - [nil, Hash, Nucleon::Config] *config*  Configurations to evaluate and possibly convert
  #   - [Array<String, Symbol>, String, Symbol] *contexts*  Context names to include in list
  #   - [Array<String, Symbol>, String, Symbol] *hierarchy*  Hierarchy of prefixes to apply to given contexts
  #   - [Hash] *defaults*  Configuration defaults that may be overridden by config data
  #   - [Boolean] *force*  Whether or not to force override of values where types don't match during merge
  #   - [Boolean] *basic_merge*  Whether or not to perform a basic merge or deep (recursive) merge
  #
  # * *Returns*
  #   - [Nucleon::Config]  Returns configuration object
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Config::Options
  # - Nucleon::Mixin::ConfigOptions#contexts
  # - Nucleon::Mixin::ConfigOptions#get_options
  # - ::new
  # - #import
  # - Util::Data::empty?
  #
  def self.init(options, contexts = [], hierarchy = [], defaults = {}, force = true, basic_merge = true)
    contexts = contexts(contexts, hierarchy)
    config   = new(get_options(contexts), defaults, force, basic_merge)
    config.import(options) unless Util::Data.empty?(options)
    return config
  end

  # Initialize a new configuration object with contextualized defaults from the
  # global configuration option collection (no hierarchical support).
  #
  # This method is not really used much within Nucleon itself, but is used to
  # help create the corl gem Puppet interface that forms the provisioner
  # configurations for resource creation based on options defined in Puppet.
  #
  # Example:
  #
  #   Nucleon::Config::set_options([ :context1, :context2 ], { :my_property => 'value' })
  #
  #   config = Nucleon::Config.init_flat({ :other_property => 'something' }, :context2)
  #   config.export
  #   # {
  #   #   :my_property => 'value',
  #   #   :other_property => 'something'
  #   # }
  #
  # * *Parameters*
  #   - [nil, Hash, Nucleon::Config] *config*  Configurations to evaluate and possibly convert
  #   - [Array<String, Symbol>, String, Symbol] *contexts*  Context names to include in list
  #   - [Hash] *defaults*  Configuration defaults that may be overridden by config data
  #   - [Boolean] *force*  Whether or not to force override of values where types don't match during merge
  #   - [Boolean] *basic_merge*  Whether or not to perform a basic merge or deep (recursive) merge
  #
  # * *Returns*
  #   - [Nucleon::Config]  Returns configuration object
  #
  # * *Errors*
  #
  # See:
  # - ::init
  #
  def self.init_flat(options, contexts = [], defaults = {}, force = true, basic_merge = true)
    return init(options, contexts, [], defaults, force, basic_merge)
  end

  #*****************************************************************************
  # Constructor / Destructor

  # Initialize a new configuration object with given options and defaults.
  #
  # The defaults are split out from the original options because we have found
  # it handy to have them initialized from two different data objects.  Defaults
  # are only set if the original data lacks the default property name.
  #
  # The configuration object is ultimately designed to provide a starting point
  # for creating distributed objects, which are easily loaded, dumped, and merged
  # to form composite objects.
  #
  # The configuration serves as the framework base class to all Nucleon plugins,
  # core objects, and a few utilities.  This class is the most important object
  # in the entire Nucleon framework, as it is used the most.
  #
  # Example:
  #
  #   config = Nucleon::Config.new({ :other_property => 'something' }, {
  #     :my_property => 'default',
  #     :other_property => 'default'
  #   })
  #   config.export
  #   # {
  #   #   :my_property => 'default',
  #   #   :other_property => 'something'
  #   # }
  #
  # * *Parameters*
  #   - [nil, Hash, Nucleon::Config] *data*  Configurations to evaluate and possibly convert
  #   - [Hash] *defaults*  Configuration defaults that may be overridden by config data
  #   - [Boolean] *force*  Whether or not to force override of values where types don't match during merge
  #   - [Boolean] *basic_merge*  Whether or not to perform a basic merge or deep (recursive) merge
  #
  # * *Returns*
  #   - [Nucleon::Config]  Returns configuration object
  #
  # * *Errors*
  #
  # See also:
  # - ::ensure
  # - ::init
  # - ::init_flat
  # - #symbol_map
  # - #export
  # - Nucleon::Util::Data::merge
  #
  def initialize(data = {}, defaults = {}, force = true, basic_merge = true)
    @force       = force
    @basic_merge = basic_merge
    @properties  = {}

    if defaults.is_a?(Hash) && ! defaults.empty?
      defaults = symbol_map(defaults.clone)
    end

    case data
    when Nucleon::Config
      @properties = Util::Data.merge([ defaults, data.export ], force, basic_merge)
    when Hash
      @properties = {}
      if data.is_a?(Hash)
        @properties = Util::Data.merge([ defaults, symbol_map(data.clone) ], force, basic_merge)
      end
    else
      @properties = defaults if defaults.is_a?(Hash)
    end
  end

  #*****************************************************************************
  # Checks

  # Check whether or not this configuration object is empty.
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Boolean]  Whether or not configuration object is empty
  #
  # * *Errors*
  #
  def empty?
    @properties.empty?
  end

  # Check whether or not this configuration object has a specific key.
  #
  # The purpose of this method is to provide a complimentary has_key? method to
  # the Hash class so we can check either interchangeably.
  #
  # * *Parameters*
  #   - [Array<String, Symbol>, String, Symbol] *keys*  Key path to check
  #
  # * *Returns*
  #   - [Boolean]  Whether or not configuration object has a specific key
  #
  # * *Errors*
  #
  # See:
  # - #get
  #
  def has_key?(keys)
    get(keys).nil? ? false : true
  end

  #*****************************************************************************
  # Property accessors / modifiers

  # Return all of the keys for the configuration properties hash.
  #
  # The purpose of this method is to provide a complimentary keys method to
  # the Hash class so we can return either interchangeably.
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Array<Symbol>]  Array of existing configuration properties
  #
  # * *Errors*
  #
  def keys
    @properties.keys
  end

  # Recursively fetch value for key path in the configuration object.
  #
  # This method serves as a base accessor to the properties that are defined in
  # the central property collection.  It is used and built upon by other
  # accessors defined in the class.
  #
  # Hash data is assumed to already be symbolized.
  #
  # * *Parameters*
  #   - [Hash] *data*  Configuration property data
  #   - [Array<String, Symbol>, String, Symbol] *keys*  Key path to fetch
  #   - [ANY] *default*  Default value is no value is found for key path
  #   - [false, Symbol, String] *format*  Format to filter final returned value or false for none
  #
  # * *Returns*
  #   - [ANY]  Filtered value for key path from configuration object
  #
  # * *Errors*
  #
  # See:
  # - #filter
  # - Nucleon::Util::Data::filter
  #
  def fetch(data, keys, default = nil, format = false)
    if keys.is_a?(String) || keys.is_a?(Symbol)
      keys = [ keys ]
    end

    keys = keys.flatten.compact
    key  = keys.shift.to_sym

    if data.has_key?(key)
      value = data[key]

      if keys.empty?
        return filter(value, format)
      else
        return fetch(data[key], keys, default, format) if data[key].is_a?(Hash)
      end
    end
    return filter(default, format)
  end
  protected :fetch

  # Modify value for key path in the configuration object.
  #
  # This method serves as a base modifier to the properties that are defined in
  # the central property collection.  It is used and built upon by other
  # modifiers defined in the class.
  #
  # Hash data is assumed to already be symbolized.
  #
  # * *Parameters*
  #   - [Hash] *data*  Configuration property data
  #   - [Array<String, Symbol>, String, Symbol] *keys*  Key path to modify
  #   - [ANY] *value*  Value to set for key path
  #   - [Boolean] *delete_nil*  Delete nil value (serves as an internal way to delete properties)
  #
  # * *Returns*
  #   - [ANY]  Existing value for key path from configuration object (before update)
  #
  # * *Errors*
  #
  # See:
  # - #symbol_map
  # - Nucleon::Util::Data::symbol_map
  #
  def modify(data, keys, value = nil, delete_nil = false)
    if keys.is_a?(String) || keys.is_a?(Symbol)
      keys = [ keys ]
    end

    keys     = keys.flatten.compact
    key      = keys.shift.to_sym
    has_key  = data.has_key?(key)
    existing = {
      :key   => key,
      :value => ( has_key ? data[key] : nil )
    }

    if keys.empty?
      existing[:value] = data[key] if has_key

      if value.nil? && delete_nil
        data.delete(key) if has_key
      else
        value     = symbol_map(value) if value.is_a?(Hash)
        data[key] = value
      end
    else
      data[key] = {} unless has_key

      if data[key].is_a?(Hash)
        existing = modify(data[key], keys, value, delete_nil)
      else
        existing[:value] = nil
      end
    end

    return existing
  end
  protected :modify

  # Fetch value for key path in the configuration object.
  #
  # * *Parameters*
  #   - [Array<String, Symbol>, String, Symbol] *keys*  Key path to fetch
  #   - [ANY] *default*  Default value is no value is found for key path
  #   - [false, Symbol, String] *format*  Format to filter final returned value or false for none
  #
  # * *Returns*
  #   - [ANY]  Filtered value for key path from configuration object
  #
  # * *Errors*
  #
  # See:
  # - #fetch
  #
  # See also:
  # - #array
  #
  def get(keys, default = nil, format = false)
    return fetch(@properties, array(keys).flatten, default, format)
  end

  # Fetch value for key path in the configuration object.
  #
  # This method is really just to provide an easier interface compatible with
  # Hash access for simpler configuration groups.
  #
  # * *Parameters*
  #   - [String, Symbol] *name*  Key to fetch
  #   - [ANY] *default*  Default value is no value is found for key
  #   - [false, Symbol, String] *format*  Format to filter final returned value or false for none
  #
  # * *Returns*
  #   - [ANY]  Filtered value for key path from configuration object
  #
  # * *Errors*
  #
  # See:
  # - #get
  #
  def [](name, default = nil, format = false)
    get(name, default, format)
  end

  # Fetch filtered array value for key path in the configuration object.
  #
  # * *Parameters*
  #   - [Array<String, Symbol>, String, Symbol] *keys*  Key path to fetch
  #   - [Array] *default*  Default value is no value is found for key path
  #
  # * *Returns*
  #   - [Array]  Filtered array value for key path from configuration object
  #
  # * *Errors*
  #
  # See:
  # - #get
  #
  # See also:
  # - #array
  # - Nucleon::Util::Data::array
  #
  def get_array(keys, default = [])
    return get(keys, default, :array)
  end

  # Fetch filtered hash value for key path in the configuration object.
  #
  # * *Parameters*
  #   - [Array<String, Symbol>, String, Symbol] *keys*  Key path to fetch
  #   - [Hash] *default*  Default hash value is no value is found for key path
  #
  # * *Returns*
  #   - [Hash]  Filtered hash value for key path from configuration object
  #
  # * *Errors*
  #
  # See:
  # - #get
  #
  # See also:
  # - #hash
  # - Nucleon::Util::Data::hash
  #
  def get_hash(keys, default = {})
    return get(keys, default, :hash)
  end

  # Initialize value for key path in the configuration object if one does not
  # exist yet.
  #
  # * *Parameters*
  #   - [Array<String, Symbol>, String, Symbol] *keys*  Key path to modify
  #   - [ANY] *default*  Default value to set for key path if it does not exist yet
  #
  # * *Returns*
  #   - [Nucleon::Config]  Returns reference to self for compound operations
  #
  # * *Errors*
  #
  # See:
  # - #get
  # - #set
  #
  def init(keys, default = nil)
    return set(keys, get(keys, default))
  end

  # Set value for key path in the configuration object.
  #
  # * *Parameters*
  #   - [Array<String, Symbol>, String, Symbol] *keys*  Key path to modify
  #   - [ANY] *value*  Value to set for key path
  #   - [Boolean] *delete_nil*  Delete nil value (serves as an internal way to delete properties)
  #
  # * *Returns*
  #   - [Nucleon::Config]  Returns reference to self for compound operations
  #
  # * *Errors*
  #
  # See:
  # - #modify
  #
  # See also:
  # - #array
  #
  def set(keys, value, delete_nil = false)
    modify(@properties, array(keys).flatten, value, delete_nil)
    return self
  end

  # Set value for key in the configuration object.
  #
  # This method is really just to provide an easier interface compatible with
  # Hash access for simpler configuration groups.
  #
  # * *Parameters*
  #   - [String, Symbol] *name*  Key to fetch
  #   - [ANY] *value*  Value to set for key
  #
  # * *Returns*
  #   - [Void]  Return value thrown away
  #
  # * *Errors*
  #
  # See:
  # - #set
  #
  def []=(name, value)
    set(name, value)
  end

  # Delete key path from the configuration object.
  #
  # * *Parameters*
  #   - [Array<String, Symbol>, String, Symbol] *keys*  Key path to remove
  #   - [ANY] *default*  Default value to return if no existing value found
  #
  # * *Returns*
  #   - [ANY]  Returns default or last value removed from configuration object
  #
  # * *Errors*
  #
  # See:
  # - #modify
  #
  # See also:
  # - #array
  #
  def delete(keys, default = nil)
    existing = modify(@properties, array(keys).flatten, nil, true)
    return existing[:value] unless existing[:value].nil?
    return default
  end

  # Clear all properties from the configuration object.
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Nucleon::Config]  Returns reference to self for compound operations
  #
  # * *Errors*
  #
  def clear
    @properties = {}
    return self
  end

  #*****************************************************************************
  # Import / Export

  # Base import method for the configuration object.
  #
  # This method is used to perform merge overrides of new property values and to
  # set defaults if no properties currently exist.
  #
  # If properties are given as a string or symbol and the configuration object
  # has a lookup method implemented (corl gem) then the properties will be
  # dynamically looked up and imported.
  #
  # * *Parameters*
  #   - [String, Symbol, Array, Hash] *properties*  Data to import
  #   - [Hash] *options*  Import options
  #     - [Symbol] *:import_type*  Type of import to perform; *:override* or *:default*
  #     - Options to Nucleon::Util::Data::merge
  #
  # * *Returns*
  #   - [Nucleon::Config]  Returns reference to self for compound operations
  #
  # * *Errors*
  #
  # See also:
  # - ::new
  # - #get
  # - #set
  # - #export
  # - #symbol_map
  # - Nucleon::Util::Data::merge
  #
  def import_base(properties, options = {})
    config      = Config.new(options, { :force => @force, :basic => @basic_merge }).set(:context, :hash)
    import_type = config.get(:import_type, :override)

    properties  = properties.export if properties.is_a?(Nucleon::Config)

    case properties
    when Hash
      data = [ @properties, symbol_map(properties.clone) ]
      data = data.reverse if import_type != :override

      @properties = Util::Data.merge(data, config)

    when String, Symbol
      if respond_to?(:lookup)
        properties = self.class.lookup(properties.to_s, {}, config)

        data = [ @properties, symbol_map(properties) ]
        data = data.reverse if import_type != :override

        @properties = Util::Data.merge(data, config)
      end

    when Array
      properties.clone.each do |item|
        import_base(item, config)
      end
    end

    return self
  end
  protected :import_base

  # Import new property values into the configuration object. (override)
  #
  # If properties are given as a string or symbol and the configuration object
  # has a lookup method implemented (corl gem) then the properties will be
  # dynamically looked up and imported.
  #
  # * *Parameters*
  #   - [String, Symbol, Array, Hash] *properties*  Data to import
  #   - [Hash] *options*  Import options
  #
  # * *Returns*
  #   - [Nucleon::Config]  Returns reference to self for compound operations
  #
  # * *Errors*
  #
  # See:
  # - #import_base
  #
  def import(properties, options = {})
    return import_base(properties, options)
  end

  # Set default property values in the configuration object if they don't exist.
  #
  # If defaults are given as a string or symbol and the configuration object
  # has a lookup method implemented (corl gem) then the defaults will be
  # dynamically looked up and set.
  #
  # * *Parameters*
  #   - [String, Symbol, Array, Hash] *defaults*  Data to set as defaults
  #   - [Hash] *options*  Import options
  #
  # * *Returns*
  #   - [Nucleon::Config]  Returns reference to self for compound operations
  #
  # * *Errors*
  #
  # See:
  # - #import_base
  #
  # See also:
  # - ::new
  # - #set
  #
  def defaults(defaults, options = {})
    config = Config.new(options).set(:import_type, :default)
    return import_base(defaults, config)
  end

  # Export properties into a regular hash object (cloned)
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Hash]  Returns a hash of all the configuration properties
  #
  # * *Errors*
  #
  def export
    return @properties.clone
  end

  #*****************************************************************************
  # Utilities

  # Return hash as a symbol map.
  #
  # This method converts all hash keys to symbols.  Nested hashes are
  # recursively translated as well.
  #
  # This comes in really handy when performing operations across hashes in Ruby
  # because of the distinction between symbols and strings.
  #
  # See:
  # - Nucleon::Util::Data::symbol_map
  #
  def self.symbol_map(data)
    return Util::Data.symbol_map(data)
  end

  # Return hash as a symbol map.
  #
  # See:
  # - ::symbol_map
  #
  def symbol_map(data)
    return self.class.symbol_map(data)
  end

  # Return hash as a string map.
  #
  # This method converts all hash keys to strings.  Nested hashes are
  # recursively translated as well.
  #
  # This comes in really handy when performing operations across hashes in Ruby
  # because of the distinction between symbols and strings.
  #
  # See:
  # - Nucleon::Util::Data::string_map
  #
  def self.string_map(data)
    return Util::Data.string_map(data)
  end

  # Return hash as a string map.
  #
  # See:
  # - ::string_map
  #
  def string_map(data)
    return self.class.string_map(data)
  end

  #*****************************************************************************

  # Run a defined filter on a data object.
  #
  # This method ensures that a given data object meets some criteria or else
  # an empty value for that type is returned that matches the criteria.
  #
  # Currently implemented filters:
  # 1. ::array  Ensure result is an array (non arrays are converted)
  # 2. ::hash   Ensure result is a hash (non hashes are converted)
  # 3. ::string Ensure result is a string (non strings are converted)
  # 4. ::symbol Ensure result is a symbol (non symbols are converted)
  # 5. ::test   Ensure result is not empty (runs a boolean ::empty? check)
  #
  # See:
  # - Nucleon::Util::Data::filter
  #
  def self.filter(data, method = false)
    return Util::Data.filter(data, method)
  end

  # Run a defined filter on a data object.
  #
  # See:
  # - ::filter
  #
  def filter(data, method = false)
    return self.class.filter(data, method)
  end

  #*****************************************************************************

  # Ensure a data object is an array.
  #
  # See:
  # - Nucleon::Util::Data::array
  #
  def self.array(data, default = [], split_string = false)
    return Util::Data.array(data, default, split_string)
  end

  # Ensure a data object is an array.
  #
  # See:
  # - ::array
  #
  def array(data, default = [], split_string = false)
    return self.class.array(data, default, split_string)
  end

  # Ensure a data object is a hash.
  #
  # See:
  # - Nucleon::Util::Data::hash
  #
  def self.hash(data, default = {})
    data = data.export if data.is_a?(Nucleon::Config)
    return Util::Data.hash(data, default)
  end

  # Ensure a data object is a hash
  #
  # See:
  # - ::hash
  #
  def hash(data, default = {})
    return self.class.hash(data, default)
  end

  # Ensure a data object is a string.
  #
  # See:
  # - Nucleon::Util::Data::string
  #
  def self.string(data, default = '')
    return Util::Data.string(data, default)
  end

  # Ensure a data object is a string.
  #
  # See:
  # - ::string
  #
  def string(data, default = '')
    return self.class.string(data, default)
  end

  # Ensure a data object is a symbol.
  #
  # See:
  # - Nucleon::Util::Data::symbol
  #
  def self.symbol(data, default = :undefined)
    return Util::Data.symbol(data, default)
  end

  # Ensure a data object is a symbol.
  #
  # See:
  # - ::symbol
  #
  def symbol(data, default = :undefined)
    return self.class.symbol(data, default)
  end

  # Test a data object for emptiness and return boolean result.
  #
  # See:
  # - Nucleon::Util::Data::test
  #
  def self.test(data)
    return Util::Data.test(data)
  end

  # Test a data object for emptiness and return boolean result.
  #
  # See:
  # - ::test
  #
  def test(data)
    return self.class.test(data)
  end
end
end
