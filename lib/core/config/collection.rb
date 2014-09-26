module Nucleon
class Config
#
# == Configuration collection
#
# The Nucleon::Config::Collection class defines a container for logging properties
# and values.  This class is not currently used within Nucleon itself but it
# does serve as a configuration log for the corl gem.
#
# This basically provides standard access methods.  It implements the ability
# to dump registered properties to the file system through a machine readable
# format.
#
# How we use it in CORL:
#
# 1. As we look up configurations and modify them we save new values in global registry
# 2. When we get to the end of our execution we log them to disk so they are viewable
#
# Right now, largely for historical reasons, this class is structured as a
# global interface and collection for grouping all of the defined options.
# It was originally contained within Nucleon::Config as part of the global
# configuration interface.  In the future, this class will be refactored to
# support multiple property logs and will have more fully refined persistence
# methods.
#
# *TODO*: Mutex synchronization probably not needed?
#
# For usage:
#
# - See core configuration object Nucleon::Config
# - See configuration mixin Nucleon::Mixin::ConfigCollection
#
class Collection

  #*****************************************************************************
  # Property accessor / modifiers

  # Global access lock
  #
  # *TODO*: Might not be needed?
  #
  @@lock = Mutex.new

  # Global property collection
  #
  # Structure: @@properties[property] = value
  #
  @@properties = {}

  # Return a reference to all of the globally defined properties.
  #
  # This method generally should not be used in favor of the ::get method.
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Hash<Symbol|ANY>]  Global reference to property registry
  #
  # * *Errors*
  #
  def self.all
    @@properties
  end

  # Return specified property value.
  #
  # * *Parameters*
  #   - [String, Symbol] *name*  Property name to return value
  #
  # * *Returns*
  #   - [ANY]  Specified property value
  #
  # * *Errors*
  #
  def self.get(name)
    value = nil
    @@lock.synchronize do
      value = @@properties[name.to_sym]
    end
    value
  end

  # Set property value.
  #
  # * *Parameters*
  #   - [String, Symbol] *name*  Property name to set value
  #   - [ANY] *value*  Specified property value
  #
  # * *Returns*
  #   - [Void]  This method does not currently have a return value
  #
  # * *Errors*
  #
  def self.set(name, value)
    @@lock.synchronize do
      @@properties[name.to_sym] = value
    end
  end

  # Delete property from collection.
  #
  # * *Parameters*
  #   - [String, Symbol] *name*  Property name to remove
  #
  # * *Returns*
  #   - [Void]  This method does not currently have a return value
  #
  # * *Errors*
  #
  def self.delete(name)
    @@lock.synchronize do
      @@properties.delete(name.to_sym)
    end
  end

  # Clear all properties from the collection.
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Void]  This method does not currently have a return value
  #
  # * *Errors*
  #
  def self.clear
    @@lock.synchronize do
      @@properties = {}
    end
  end

  # Dump properties to disk.
  #
  # This class was originally designed as a logging mechanism so it is focused
  # on providing write methods so far.  Notice the missing load() method.
  #
  # The property dump must be explicitly enabled with the :config_store option.
  #
  # *TODO*:
  # 1. This method will undergo a large'ish transformation in the future as it
  #    is rewritten to make it more flexible.
  # 2. Throw appropriate error if write fails.
  #
  # * *Parameters*
  #   - [Hash<Symbol|ANY>] *options*  Method options
  #     - [String] *:log_dir*  Directory to store the log files
  #     - [String] *:log_name*  Name of the log file (*no dot or extension*)
  #     - [Boolean] *:config_store*  Check whether configurations should be stored
  #
  # * *Returns*
  #   - [Void]  This method does not currently have a return value
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Util::Data::empty?
  # - Nucleon::Util::Data.string_map
  # - Nucleon::Util::Data::to_json
  # - Nucleon::Util::Data::to_yaml
  #
  def self.save(options = {})
    unless Util::Data.empty?(options[:log_dir])
      @@lock.synchronize do
        log_dir  = options[:log_dir]

        log_name = options[:log_name]
        log_name = 'properties' unless log_name

        if options[:config_store]
          unless File.directory?(log_dir)
            FileUtils.mkdir_p(log_dir)
          end
          Util::Disk.write(File.join(log_dir, "#{log_name}.json"), Util::Data.to_json(@@properties, true))
          Util::Disk.write(File.join(log_dir, "#{log_name}.yaml"), Util::Data.to_yaml(Util::Data.string_map(@@properties)))
        end
      end
    end
  end
end
end
end
