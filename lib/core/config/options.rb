module Nucleon
class Config
#
# == Contextualized option collection
#
# The Nucleon::Config::Options class defines a container for contextualized
# access of grouped properties.
#
# This basically does three things:
#
# 1. Group properties by contextual identifiers and store in a centralized location
# 2. Access all defined properties for one or more contextual identifiers
# 3. Clear contextual properties
#
# Right now, largely for historical reasons, this class is structured as a
# global interface and collection for grouping all of the defined options.
# It was originally contained within Nucleon::Config as part of the global
# configuration interface.  In the future, this class will be refactored to
# support multiple collections of contextualized properties.
#
# For usage:
#
# - See core configuration object Nucleon::Config::init
# - See configuration mixin Nucleon::Mixin::ConfigOptions
#
class Options

  #*****************************************************************************
  # Property accessors / modifiers

  # Global contextualized property collection
  #
  # Structure: @@options[context_name][property] = value
  #
  @@options = {}

  # Return an array of context names based on given contexts and an optional
  # hierarchy path.
  #
  # This method mainly exists to allow us to create cascading context groups
  # for the properties based on a hierarchical list.  We use it to create
  # contextual property lookups for configuring Puppet in the corl gem.
  #
  # For example:
  #
  #  contexts = Nucleon::Config::Options.contexts([ :parameter, :var_name ], :module)
  #  contexts = [
  #    'all',
  #    'parameter',
  #    'var_name',
  #    'module_parameter',
  #    'module_var_name'
  #  ]
  #
  # * *Parameters*
  #   - [Array<String, Symbol>, String, Symbol] *contexts*  Context names to include in list
  #   - [Array<String, Symbol>, String, Symbol] *hierarchy*  Hierarchy of prefixes to apply to given contexts
  #
  # * *Returns*
  #   - [Array<String>]  Generated array of ordered context names
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Util::Data::empty?
  # - Nucleon::Util::Data::prefix
  #
  def self.contexts(contexts = [], hierarchy = [])
    contexts = [ 'all', contexts ].flatten
    results  = contexts

    unless hierarchy.is_a?(Array)
      hierarchy = ( ! Util::Data.empty?(hierarchy) ? [ hierarchy ].flatten : [] )
    end

    hierarchy.each do |group|
      group_contexts = Util::Data.prefix(group, contexts)
      results        = [ results, group_contexts ].flatten
    end

    return results
  end

  # Return a reference to all of the globally defined context properties.
  #
  # This method generally should not be used in favor of the ::get method.
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Hash<Symbol|Symbol|ANY>]  Global reference to option registry
  #
  # * *Errors*
  #
  def self.all
    @@options
  end

  # Return merged option groups for given context names.
  #
  # This method allows us to easily request combinations of properties.
  #
  # For example:
  #
  #  Nucleon::Config::Options.set(:context1, { :property1 => 'some value' })
  #  Nucleon::Config::Options.set(:context2, { :property2 => 'another value' })
  #
  #  options = Nucleon::Config::Options.get([ :context1, :context2 ])
  #  options = {
  #    :property1 => 'some value',
  #    :property2 => 'another value'
  #  }
  #
  # * *Parameters*
  #   - [Array<String, Symbol>, String, Symbol] *contexts*  Context names to aggregate
  #   - [Boolean] *force*  Force merge override if different types of data being merged
  #
  # * *Returns*
  #   - [Hash<Symbol|ANY>]  Aggregated context property collection
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Util::Data::empty?
  # - Nucleon::Util::Data::merge
  #
  def self.get(contexts, force = true)
    options = {}

    unless contexts.is_a?(Array)
      contexts = ( ! Util::Data.empty?(contexts) ? [ contexts ].flatten : [] )
    end
    contexts.each do |name|
      name = name.to_sym
      if @@options.has_key?(name)
        options = Util::Data.merge([ options, @@options[name] ], force, false)
      end
    end
    return options
  end

  # Assign property values to specified context identifiers.
  #
  # This method allows us to easily merge properties across various contexts.
  #
  # For example, see ::get method
  #
  # * *Parameters*
  #   - [Array<String, Symbol>, String, Symbol] *contexts*  Context names to assign properties
  #   - [Hash<String, Symbol|ANY>] *options*  Property collection to merge with existing properties
  #   - [Boolean] *force*  Force merge override if different types of data being merged
  #
  # * *Returns*
  #   - [Void]  This method does not currently have a return value
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Util::Data::empty?
  # - Nucleon::Util::Data::merge
  #
  def self.set(contexts, options, force = true)
    unless contexts.is_a?(Array)
      contexts = ( ! Util::Data.empty?(contexts) ? [ contexts ].flatten : [] )
    end
    contexts.each do |name|
      name = name.to_sym
      current_options = ( @@options.has_key?(name) ? @@options[name] : {} )
      @@options[name] = Util::Data.merge([ current_options, Config.symbol_map(options) ], force, false)
    end
  end

  # Clear all properties for specified contexts.
  #
  # Contexts are entirely removed, even the name itself.  If nil is given (default)
  # then all data is removed and options are reinitialized.
  #
  # * *Parameters*
  #   - [nil, Array<String, Symbol>, String, Symbol] *contexts*  Context names to remove
  #
  # * *Returns*
  #   - [Void]  This method does not currently have a return value
  #
  # * *Errors*
  #
  def self.clear(contexts = nil)
    if contexts.nil?
      @@options = {}
    else
      unless contexts.is_a?(Array)
        contexts = [ contexts ]
      end
      contexts.each do |name|
        @@options.delete(name.to_sym)
      end
    end
  end
end
end
end
