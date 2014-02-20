
module Nucleon
module Util
class Interface
  
  #-----------------------------------------------------------------------------
  # Properties
  
  @@log_level = nil
  @@loggers   = {}
  
  def self.log_level
    @@log_level  
  end
  
  def self.log_level=level
    @@log_level = set_log_level(level)
  end
  
  #---
  
  def self.loggers
    @@loggers
  end
  
  def self.add_log_levels(*levels)
    levels = levels.flatten.collect do |level| 
      level.to_s.upcase
    end
    Log4r::Configurator.custom_levels(*levels)
  end
  
  def self.add_logger(name, logger)
    logger.outputters = Log4r::StdoutOutputter.new('console')
    
    level = log_level.nil? ? 'off' : log_level
    set_log_level(level, logger)  
        
    @@loggers[name] = logger
  end
  
  def self.set_log_level(level, logger = nil)
    level_sym   = level.to_s.downcase.to_sym
    level_id    = level.to_s.upcase
    
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
  
  # Initialize log levels
  
  add_log_levels :debug, :info, :warn, :error, :hook
    
  if ENV['NUCLEON_LOG']
    Interface.log_level = ENV['NUCLEON_LOG']
  end
    
  #---
  
  @@ui_lock = Mutex.new
  
  #---

  COLORS = {
    :clear  => "\e[0m",
    :red    => "\e[31m",
    :green  => "\e[32m",
    :yellow => "\e[33m"
  }

  COLOR_MAP = {
    :warn    => COLORS[:yellow],
    :error   => COLORS[:red],
    :success => COLORS[:green]
  }

  #-----------------------------------------------------------------------------
  # Constructor
  
  def initialize(options = {})
    if options.is_a?(String)
      options = { :resource => options, :logger => options }
    end
    config = Config.ensure(options)
    
    @resource = config.get(:resource, '')
    
    if config.get(:logger, false)
      self.logger = config[:logger]
    else
      self.logger = Log4r::Logger.new(@resource)
    end     
    
    @color   = config.get(:color, true)    
    @printer = config.get(:printer, :puts)
    
    @input  = config.get(:input, $stdin)
    @output = config.get(:output, $stdout)
    @error  = config.get(:error, $stderr)
    
    @delegate = config.get(:ui_delegate, nil)
  end

  #---
  
  def inspect
    "#<#{self.class}: #{@resource}>"
  end
   
  #-----------------------------------------------------------------------------
  # Accessors / Modifiers
  
  attr_reader :logger
  attr_accessor :resource, :color, :input, :output, :error, :delegate
  
  #---
  
  def logger=logger
    if logger.is_a?(String)
      @logger = Log4r::Logger.new(logger)
    else
      @logger = logger
    end
    self.class.add_logger(@resource, @logger)  
  end
  
  #-----------------------------------------------------------------------------
  # UI functionality

  def say(type, message, options = {})
    return @delegate.say(type, message, options) if check_delegate('say')
    
    defaults = { :new_line => true, :prefix => true }
    options  = defaults.merge(options)
    printer  = options[:new_line] ? :puts : :print
    channel  = type == :error || options[:channel] == :error ? @error : @output
    
    options[:sync] = true unless options.has_key?(:sync)
    
    render = lambda do 
      safe_puts(format_message(type, message, options),
                :channel => channel, :printer => printer)  
    end
    
    if options[:sync]
      @@ui_lock.synchronize do
        render.call
      end
    else
      render.call
    end
  end
  
  #---

  def ask(message, options = {})
    return @delegate.ask(message, options) if check_delegate('ask')

    options[:new_line] = false if ! options.has_key?(:new_line)
    options[:prefix] = false if ! options.has_key?(:prefix)
    options[:echo] = true if ! options.has_key?(:echo)
    
    options[:sync] = true unless options.has_key?(:sync)
    
    user_input = nil
    
    collect = lambda do 
      say(:info, message, Config.ensure(options).import({ :sync => false }).export)
      
      if options[:echo]
        user_input = @input.gets.chomp
      else
        require 'io/console'        
        user_input = @input.noecho(&:gets).chomp
      end
      safe_puts("\n")
      user_input  
    end

    if options[:sync]
      @@ui_lock.synchronize do
        return collect.call
      end
    else
      return collect.call  
    end
  end
  
  #---
  
  def password(type, options = {})
    return @delegate.password(type, options) if check_delegate('password')
    
    options[:sync] = true unless options.has_key?(:sync)
    
    collect = lambda do
      try_again = true
      password  = nil
      
      while try_again
        # Get and check a password from the keyboard
        password              = ask("Enter #{type} password: ", { :echo => false, :sync => false })
        confirmation_password = ask("Confirm #{type} password: ", { :echo => false, :sync => false })
    
        if password != confirmation_password
          choice    = ask('Passwords do not match!  Try again? (Y|N): ', { :sync => false })
          try_again = choice.upcase == "Y"
          password  = nil unless try_again
        else
          try_again = false
        end
      end
      password
    end
    
    if options[:sync]
      @@ui_lock.synchronize do
        return collect.call
      end
    else
      return collect.call  
    end
  end
  
  #-----------------------------------------------------------------------------
  
  def info(message, *args)
    @logger.info("info: #{message}")
    
    return @delegate.info(message, *args) if check_delegate('info')
    say(:info, message, *args)
  end
  
  #---
  
  def warn(message, *args)
    @logger.info("warn: #{message}")
    
    return @delegate.warn(message, *args) if check_delegate('warn')
    say(:warn, message, *args)
  end
  
  #---
  
  def error(message, *args)
    @logger.info("error: #{message}")
    
    return @delegate.error(message, *args) if check_delegate('error')
    say(:error, message, *args)
  end
  
  #---
  
  def success(message, *args)
    @logger.info("success: #{message}")
    
    return @delegate.success(message, *args) if check_delegate('success')
    say(:success, message, *args)
  end
  
  #-----------------------------------------------------------------------------
  # Utilities

  def format_message(type, message, options = {})
    return @delegate.format_message(type, message, options) if check_delegate('format_message')    
    return '' if message.to_s.strip.empty?
    
    if @resource && ! @resource.empty? && options[:prefix]
      prefix = "[#{@resource}]"
    end
    message = "#{prefix} #{message}".lstrip.gsub(/\n+$/, '')
    
    if @color
      if options.has_key?(:color)
        color = COLORS[options[:color]]
        message = "#{color}#{message}#{COLORS[:clear]}"
      else
        message = "#{COLOR_MAP[type]}#{message}#{COLORS[:clear]}" if COLOR_MAP[type]
      end
    end
    return message
  end

  #---
  
  def safe_puts(message = nil, options = {})
    return @delegate.safe_puts(message, options) if check_delegate('safe_puts')
    
    message ||= ""
    options = {
      :channel => @output,
      :printer => @printer,
    }.merge(options)

    begin
      options[:channel].send(options[:printer], message)
    rescue Errno::EPIPE
      return
    end
  end
  
  #-----------------------------------------------------------------------------
  
  def check_delegate(method)
    return ( @delegate && @delegate.respond_to?(method.to_s) )
  end
end
end
end