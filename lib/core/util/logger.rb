module Nucleon
module Util
#
# == Logger
#
# The Nucleon::Util::Logger class defines a logging interface that wraps the Log4r
# gem interface to provide all Nucleon classes with logging capabilities.
#
# Logging methods exposed:
#
# 1. *error*  Display all serious errors
# 2. *warn*  Warnings that do not trigger an error
# 3. *info*  Concise runtime information
# 4. *debug*  Potentially verbose debug information
#
# *Note*:  This is the first Nucleon library loaded so it can *NOT* depend on
# any other library or core object.
#
# See also:
# - Nucleon::Core (base logging capable object)
#
class Logger

  #*****************************************************************************
  # Properties

  #
  # Global log level
  #
  # Can be:
  # - *:debug*
  # - *:info*
  # - *:warn*
  # - *:error*
  #
  @@level = nil

  #
  # Global collection of instantiated loggers
  #
  @@loggers = {}

  # Check current global log level
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Symbol]  Global log level; *:debug*, *:info*, *:warn*, *:error*
  #
  # * *Errors*
  #
  # See also:
  # - ::level=
  #
  def self.level
    @@level
  end

  # Set current global log level
  #
  # * *Parameters*
  #   - [Symbol] *level*  Global log level; *:debug*, *:info*, *:warn*, *:error*
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - ::level
  # - ::set_level
  #
  def self.level=level
    @@level = set_level(level)
  end

  # Return a reference to all globally instantiated loggers
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Hash<Symbol|Log4r>]  Collection of globally accessible loggers
  #
  # * *Errors*
  #
  def self.loggers
    @@loggers
  end

  # Define a list of Log4r levels
  #
  # Due to how Log4r is built this can only happen at the very beginning of our
  # execution run before any loggers are instantiated.
  #
  # This should never be called directly outside of this class.
  #
  # * *Parameters*
  #   - [Symbol, String, Array<Symbol, String>] *levels*  Available log levels
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  def self.set_levels(*levels)
    levels = levels.flatten.collect do |level|
      level.to_s.upcase
    end
    Log4r::Configurator.custom_levels(*levels)
  end

  # Set the logging level for either all instantiated loggers or a specified logger.
  #
  # * *Parameters*
  #   - [Symbol, String] *level*  Global log level; *:debug*, *:info*, *:warn*, *:error*
  #   - [Log4r] *logger*  Log4r instance to set log level or all if none provided
  #
  # * *Returns*
  #   - [Symbol]  Return the current global log level
  #
  # * *Errors*
  #
  # See also:
  # - ::level=
  #
  def self.set_level(level, logger = nil)
    level_sym = level.to_s.downcase.to_sym
    level_id  = level.to_s.upcase

    if logger.nil?
      loggers.each do |name, registered_logger|
        @@loggers[name].level = Log4r.const_get(level_id)
      end
    else
      if logger.levels.include?(level_id)
        logger.level = Log4r.const_get(level_id)
      end
    end
    level_sym
  end

  # Add a instantiated logger to the global logger registry.
  #
  # TODO: Is there a better way to handle the outputter for more flexibility?
  #
  # * *Parameters*
  #   - [Symbol, String] *name*  Logger name
  #   - [Log4r] *logger*  Log4r instance to register
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - ::set_level
  #
  def self.add_logger(name, logger)
    logger.outputters = Log4r::StdoutOutputter.new('console')

    level = Logger.level.nil? ? 'off' : Logger.level
    set_level(level, logger)

    @@loggers[name.to_sym] = logger
  end

  #
  # Initialize log levels
  #
  # *IMPORTANT*  Log levels must be registered before Log4r instances are created
  #
  # TODO: This process does not work when using as a library through another
  # executable that already loads Log4r.
  #
  set_levels :debug, :info, :warn, :error

  #
  # Set starting log level if defined in "NUCLEON_LOG" environment variable
  #
  if ENV['NUCLEON_LOG']
    Logger.level = ENV['NUCLEON_LOG']
  end

  #*****************************************************************************
  # Constructor

  # Initialize a new logging object
  #
  # TODO: Figure out some way to make the logger system pluggable?
  #
  # * *Parameters*
  #   - [Hash] *options*  Logger options
  #     - [String] *:resource*  Logger resource identifier (also serves as prefix)
  #     - [nil, Log4r] *:logger*  Log4r logger of nil if new one created
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - #logger=
  # - Nucleon::Config::ensure
  #
  def initialize(options = {})
    if options.is_a?(String)
      options = { :logger => options }
    end
    config = Config.ensure(options)

    @resource = config.get(:resource, '')

    if config.get(:logger, false)
      self.logger = config[:logger]
    else
      self.logger = Log4r::Logger.new(@resource)
    end
  end

  # Return a string reference that identifies this logger
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [String]  Identification string
  #
  # * *Errors*
  #
  def inspect
    "#<#{self.class}: #{@resource}>"
  end

  #*****************************************************************************
  # Accessors / Modifiers

  #
  # [String]  Logger resource name
  #
  # This is the string identifier and logger prefix used when logging.
  #
  attr_reader :resource

  # Set current logger object
  #
  # * *Parameters*
  #   - [String, Log4r] *logger*  Log4r object or string resource name
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - ::add_logger
  #
  def logger=logger
    if logger.is_a?(String)
      @resource = logger
      @logger   = Log4r::Logger.new(logger)
    else
      @logger = logger
    end
    self.class.add_logger(@resource, @logger) unless self.class.loggers.has_key?(@resource)
  end

  # Set instance logger level
  #
  # NOTE: This will detach the logger from the global log level!
  #
  # * *Parameters*
  #   - [Integer] *level*  Log4r::Logger level
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - Log4r::Logger
  #
  def level=level
    @logger.level = level unless level.nil?
  end

  # Get instance logger level
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Integer]  Return current Log4r::Logger level
  #
  # * *Errors*
  #
  # See also:
  # - Log4r::Logger
  #
  def level
    @logger.level
  end

  #*****************************************************************************
  # Log statements

  # Log a debug message
  #
  # * *Parameters*
  #   - [String] *message*  Debug related message
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Util::Console::quiet
  #
  def debug(message)
    unless Util::Console.quiet
      @logger.debug(message)
    end
  end

  # Log an info message
  #
  # * *Parameters*
  #   - [String] *message*  Concise informational message
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Util::Console::quiet
  #
  def info(message)
    unless Util::Console.quiet
      @logger.info(message)
    end
  end

  # Log a warning message (non error)
  #
  # * *Parameters*
  #   - [String] *message*  Warning message
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Util::Console::quiet
  #
  def warn(message)
    unless Util::Console.quiet
      @logger.warn(message)
    end
  end

  # Log an error message
  #
  # * *Parameters*
  #   - [String] *message*  Error message
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Util::Console::quiet
  #
  def error(message)
    unless Util::Console.quiet
      @logger.error(message)
    end
  end
end
end
end
