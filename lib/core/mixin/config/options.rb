module Nucleon
module Mixin
#
# == Contextualized option collection
#
# The Nucleon::Mixin::ConfigOptions module extends a class to include methods
# for working with the central option collection.
#
# Right now, largely for historical reasons, the Nucleon::Config::Options class
# is structured as a global interface and collection for grouping all of the
# defined options.  It was originally contained within Nucleon::Config as part
# of the global configuration interface.  In the future, the class and this
# mixin will be refactored to support multiple collections of contextualized
# properties.
#
#
# For usage and definition:
#
# - See core configuration object Nucleon::Config
# - See collection Nucleon::Config::Options
#
module ConfigOptions

  #*****************************************************************************
  # Configuration options interface

  # Return an array of context names based on given contexts and an optional
  # hierarchy path.
  #
  # This method mainly exists to allow us to create cascading context groups
  # for the properties based on a hierarchical list.  We use it to create
  # contextual property lookups for configuring Puppet in the corl gem.
  #
  # See:
  # - Nucleon::Config::Options::contexts
  #
  def contexts(contexts = [], hierarchy = [])
    Config::Options.contexts(contexts, hierarchy)
  end

  # Return a reference to all of the globally defined context properties.
  #
  # This method generally should not be used in favor of the ::get method.
  #
  # See:
  # - Nucleon::Config::Options::all
  #
  def all_options
    Config::Options.all
  end

  # Return merged option groups for given context names.
  #
  # This method allows us to easily request combinations of properties.
  #
  # See:
  # - Nucleon::Config::Options::get
  #
  def get_options(contexts, force = true)
    Config::Options.get(contexts, force)
  end

  # Assign property values to specified context identifiers.
  #
  # This method allows us to easily merge properties across various contexts.
  #
  # See:
  # - Nucleon::Config::Options::set
  #
  def set_options(contexts, options, force = true)
    Config::Options.set(contexts, options, force)
  end

  # Clear all properties for specified contexts.
  #
  # Contexts are entirely removed, even the name itself.
  #
  # See:
  # - Nucleon::Config::Options::clear
  #
  def clear_options(contexts = nil)
    Config::Options.clear(contexts)
  end
end
end
end
