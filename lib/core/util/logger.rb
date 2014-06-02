
module Nucleon
module Util
class Logger
  
  #-----------------------------------------------------------------------------
  # Properties
  
  @@level   = nil
  @@loggers = {}
  
  #---
  
  def self.level
    @@level  
  end
  
  def self.level=level
    @@level = set_level(level)
  end
  
  #---
  
  def self.loggers
    @@loggers
  end
  
  #---
  
  def self.set_levels(*levels)
    levels = levels.flatten.collect do |level| 
      level.to_s.upcase
    end
    Log4r::Configurator.custom_levels(*levels)
  end
  
  #---
  
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
  
  #---
  
  def self.add_logger(name, logger)
    logger.outputters = Log4r::StdoutOutputter.new('console')
    
    level = Logger.level.nil? ? 'off' : Logger.level
    set_level(level, logger)  
        
    @@loggers[name] = logger
  end
  
  # Initialize log levels
  
  set_levels :debug, :info, :warn, :error, :hook
    
  if ENV['NUCLEON_LOG']
    Logger.level = ENV['NUCLEON_LOG']
  end
  
  #-----------------------------------------------------------------------------
  # Constructor
  
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

  #---
  
  def inspect
    "#<#{self.class}: #{@resource}>"
  end
   
  #-----------------------------------------------------------------------------
  # Accessors / Modifiers
  
  attr_reader :resource
  
  #---
  
  def logger=logger
    if logger.is_a?(String)
      @resource = logger
      @logger   = Log4r::Logger.new(logger)
    else
      @logger = logger
    end
    self.class.add_logger(@resource, @logger) unless self.class.loggers.has_key?(@resource)  
  end
  
  #-----------------------------------------------------------------------------
  # Log statements
  
  def debug(message)
    @logger.debug(message)
  end
  
  #---
  
  def info(message)
    @logger.info(message)
  end
  
  #---
  
  def warn(message)
    @logger.warn(message)
  end
  
  #---
  
  def error(message)
    @logger.error(message)
  end
  
  #---
  
  def hook(message)
    @logger.hook(message)  
  end          
end
end
end
