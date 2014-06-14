
module Nucleon
module Util
class Console
  
  # Flush output immediately.
  $stderr.sync = true
  $stdout.sync = true
  
  #---
  
  @@console_lock = Mutex.new
  @@quiet        = false
  @@use_colors   = true
  
  #---

  @@colors = {
    :clear  => "\e[0m",
    :black  => "\e[30m",
    :red    => "\e[31m",
    :green  => "\e[32m",
    :yellow => "\e[33m",
    :blue   => "\e[34m",
    :purple => "\e[35m",
    :cyan   => "\e[36m",
    :grey   => "\e[37m"
  }

  @@color_map = {
    :warn    => :yellow,
    :error   => :red,
    :success => :green
  }

  #-----------------------------------------------------------------------------
  # Constructor
  
  def initialize(options = {})
    if options.is_a?(String)
      options = { :resource => options }
    end
    config = Config.ensure(options)
    
    @resource = config.get(:resource, '')
    
    @color   = config.get(:color, true)    
    @printer = config.get(:printer, :puts)
    
    @input  = config.get(:input, $stdin)
    @output = config.get(:output, $stdout)
    @error  = config.get(:error, $stderr)
    
    @delegate = config.get(:console_delegate, nil)
  end

  #---
  
  def inspect
    "#<#{self.class}: #{@resource}>"
  end
   
  #-----------------------------------------------------------------------------
  # Accessors / Modifiers
  
  attr_accessor :resource, :color, :input, :output, :error, :delegate
  
  #---
  
  def self.quiet
    @@quiet
  end
  
  def self.quiet=quiet
    @@quiet = quiet
  end
  
  #---
  
  def self.use_colors
    @@use_colors && ! ENV['NUCLEON_NO_COLOR'] 
  end
  
  def self.use_colors=use_colors
    @@use_colors = use_colors
  end
  
  #-----------------------------------------------------------------------------
  # UI functionality

  def say(type, message, options = {})
    return if @@quiet && ! options[:quiet_override]
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
      @@console_lock.synchronize do
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
      say(:info, message, Config.ensure(options).import({ :sync => false, :quiet_override => true }).export)
      
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
      @@console_lock.synchronize do
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
      password.strip
    end
    
    if options[:sync]
      @@console_lock.synchronize do
        return collect.call
      end
    else
      return collect.call  
    end
  end
  
  #-----------------------------------------------------------------------------
  
  def info(message, *args)
    return @delegate.info(message, *args) if check_delegate('info')
    say(:info, message, *args)
  end
  
  #---
  
  def warn(message, *args)
    return @delegate.warn(message, *args) if check_delegate('warn')
    say(:warn, message, *args)
  end
  
  #---
  
  def error(message, *args)
    return @delegate.error(message, *args) if check_delegate('error')
    say(:error, message, *args)
  end
  
  #---
  
  def success(message, *args)
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
    message = "#{prefix} #{message}".sub(/^ +/, '')
    
    if @@use_colors && @color
      if options.has_key?(:color)
        message = self.class.colorize(message, options[:color]) 
      else
        message = self.class.colorize(message, @@color_map[type]) if @@color_map[type]
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
  
  #-----------------------------------------------------------------------------
  # Color translation
  
  def self.colorize(string, color)
    return '' unless string
    return string.to_s unless use_colors
    
    color        = color.to_sym
    string       = string.to_s
    color_string = string
    
    if @@colors[color]
      color         = @@colors[color]
      clear_color   = @@colors[:clear]
      escaped_clear = Regexp.escape(clear_color)
            
      color_string  = "#{color}"
      color_string << string.gsub(/#{escaped_clear}(?!\e\[)/, "#{clear_color}#{color}")
      color_string << "#{clear_color}"
    end
    color_string
  end
  
  #---
  
  def self.black(string)
    colorize(string, :black) 
  end
  
  #---
  
  def self.red(string)
    colorize(string, :red)   
  end
  
  #---
  
  def self.green(string)
    colorize(string, :green)  
  end
  
  #---
    
  def self.yellow(string)
    colorize(string, :yellow)  
  end
  
  #---
    
  def self.blue(string)
    colorize(string, :blue)  
  end
  
  #---
    
  def self.purple(string)
    colorize(string, :purple)  
  end
  
  #---
    
  def self.cyan(string)
    colorize(string, :cyan)   
  end
  
  #---
    
  def self.grey(string)
    colorize(string, :grey) 
  end
end
end
end
