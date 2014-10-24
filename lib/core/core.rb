module Nucleon
#
# == Core Nucleon object
#
# The Nucleon::Core class defines a minimal base class for creating other
# capable objects, combining configurations, console capabilities, and logging
# capabilities.
#
# All of the plugins build off of the Core object, as do some utility classes.
#
# Five main goals with this object:
#
# 1. Global and instance Nucleon::Util::Logger interfaces
# 2. Global and instance Nucleon::Util::Console interfaces
# 3. Include color methods
# 4. Provide contextually prefixed UI groups for console output operations
# 5. Provide an initialized lookup
#
class Core < Config

  #
  # Provide colored text rendering methods
  #
  # See:
  # - Nucleon::Mixin::Colors
  # - Nucleon::Util::Console
  #
  include Mixin::Colors

  #*****************************************************************************
  # Properties

  #
  # Global logger instance
  #
  # See:
  # - Nucleon::Util::Logger
  #
  @@logger = Util::Logger.new('core')
  #
  # Global console instance
  #
  # See:
  # - Nucleon::Util::Console
  #
  @@ui = Util::Console.new('core')
  #
  # Global UI Mutex
  #
  # TODO: This may not be needed?
  #
  @@ui_lock = Mutex.new

  #*****************************************************************************
  # Constructor / Destructor

  # Initialize a new core Nucleon object
  #
  # TODO: Figure out some way to make the console and logging systems pluggable?
  #
  # * *Parameters*
  #   - [nil, Hash, Nucleon::Config] *data*  Configurations to import
  #   - [Hash] *defaults*  Configuration defaults that may be overridden by config data
  #   - [Boolean] *force*  Whether or not to force override of values where types don't match during merge
  #   - [Boolean] *set_initialized*  Whether or not to the initialized flag is set after this object is constructed
  #   - [Boolean] *basic_merge*  Whether or not to perform a basic merge or deep (recursive) merge
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Config::new
  # - Nucleon::Config#delete
  # - Nucleon::Config#export
  # - Nucleon::Config#defaults
  # - Nucleon::Util::Data::ensure_value
  # - Nucleon::Util::Console::colorize
  #
  def initialize(data = {}, defaults = {}, force = true, set_initialized = true, basic_merge = true)
    super(data, defaults, force, basic_merge)

    @initialized = false
    @class_color = Util::Data.ensure_value(delete(:class_color, :cyan), :cyan)
    @class_label = self.class.to_s.downcase.gsub(/^nucleon::/, '')

    self.logger = delete(:logger, @class_label)
    self.ui     = Config.new(export).defaults({ :resource => Util::Console.colorize(@class_label, @class_color) })

    logger.debug('Initialized instance logger and interface')
    @initialized = true if set_initialized
  end

  #*****************************************************************************
  # Checks

  # Check if object is initialized?
  #
  # The initialized flag must be set from a method within the class.  It can not
  # be set externally.
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Boolean]  Whether or not object has been marked as initialized
  #
  # * *Errors*
  #
  def initialized?
    @initialized
  end

  #*****************************************************************************
  # Accessor / Modifiers

  #
  # [Nucleon::Util::Logger]  Instance logger
  #
  attr_reader :logger
  #
  # [Nucleon::Util::Console]  Instance console
  #
  attr_reader :ui

  # Return global logger instance
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Nucleon::Util::Logger]  Global logger instance
  #
  # * *Errors*
  #
  def self.logger
    return @@logger
  end

  # Set current object logger instance
  #
  # * *Parameters*
  #   - [String, Nucleon::Util::Logger] *logger*  Logger instance or resource name for new logger
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Util::Logger::loggers
  # - Nucleon::Util::Logger::new
  #
  def logger=logger
    Util::Logger.loggers.delete(self.logger.resource) if self.logger

    if logger.is_a?(Util::Logger)
      @logger = logger
    else
      @logger = Util::Logger.new(logger)
    end
  end

  # Return global console instance
  #
  # This is named ui for historical reasons.  It might change to console in the
  # future.
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Nucleon::Util::Console]  Global console instance
  #
  # * *Errors*
  #
  def self.ui
    return @@ui
  end

  # Set current object console instance
  #
  # * *Parameters*
  #   - [String, Nucleon::Util::Console] *ui*  Console instance or resource name for new console
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Util::Console::new
  #
  def ui=ui
    if ui.is_a?(Util::Console)
      @ui = ui
    else
      @ui = Util::Console.new(ui)
    end
  end

  #*****************************************************************************
  # General utilities

  # Contextualize console operations in a code block with a given resource name.
  #
  # TODO: May not need Mutex synchronization?
  #
  # * *Parameters*
  #   - [String, Symbol] *resource*  Console resource identifier (prefix)
  #   - [Symbol] *color*  Color to use; *:black*, *:red*, *:green*, *:yellow*, *:blue*, *:purple*, *:cyan*, *:grey*
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # * *Yields*
  #   - [Nucleon::Util::Console] *ui*  Current global console instance
  #
  # See also:
  # - Nucleon::Util::Console::colorize
  #
  def self.ui_group(resource, color = :cyan) # :yields: ui
    @@ui_lock.synchronize do
      begin
        ui_resource = ui.resource
        ui.resource = Util::Console.colorize(resource, color)
        yield(ui)

      ensure
        ui.resource = ui_resource
      end
    end
  end

  # Contextualize console operations in a code block with a given resource name.
  #
  # * *Parameters*
  #   - [String, Symbol] *resource*  Console resource identifier (prefix)
  #   - [Symbol] *color*  Color to use; *:black*, *:red*, *:green*, *:yellow*, *:blue*, *:purple*, *:cyan*, *:grey*
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # * *Yields*
  #   - [Nucleon::Util::Console] *ui*  Current object console instance
  #
  # See also:
  # - Nucleon::Util::Console::colorize
  #
  def ui_group(resource, color = :cyan) # :yields: ui
    ui_resource = ui.resource
    ui.resource = Util::Console.colorize(resource, color)
    yield(ui)

  ensure
    ui.resource = ui_resource
  end
end
end