module Nucleon
module Mixin
#
# == Configuration collection
#
# The Nucleon::Mixin::ConfigCollection module extends a class to include methods
# for working with the global property collection.
#
# Right now, largely for historical reasons, the Nucleon::Config::Collection
# class is structured as a global interface and collection for grouping all of
# the defined options.  It was originally contained within Nucleon::Config as
# part of the global configuration interface.  In the future, the class and
# this mixin will be refactored to support multiple property logs and will
# have more fully refined persistence methods.
#
#
# For usage and definition:
#
# - See core configuration object Nucleon::Config
# - See collection Nucleon::Config::Collection
#
module ConfigCollection

  #*****************************************************************************
  # Configuration collection interface

  # Return a reference to all of the globally defined properties.
  #
  # This method generally should not be used in favor of the ::get method.
  #
  # See:
  # - Nucleon::Config::Collection::all
  #
  def all_properties
    Config::Collection.all
  end

  # Return specified property value.
  #
  # See:
  # - Nucleon::Config::Collection::get
  #
  def get_property(name)
    Config::Collection.get(name)
  end

  # Set property value.
  #
  # See:
  # - Nucleon::Config::Collection::set
  #
  def set_property(name, value)
    Config::Collection.set(name, value)
  end

  # Delete property from collection.
  #
  # See:
  # - Nucleon::Config::Collection::delete
  #
  def delete_property(name)
    Config::Collection.delete(name)
  end

  # Clear all properties from the collection.
  #
  # See:
  # - Nucleon::Config::Collection::clear
  #
  def clear_properties
    Config::Collection.clear
  end

  # Dump properties to disk.
  #
  # See:
  # - Nucleon::Config::Collection::save
  #
  def save_properties(options = {})
    Config::Collection.save(options)
  end
end
end
end
