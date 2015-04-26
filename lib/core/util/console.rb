module Nucleon
module Util
#
# == Console
#
# The Nucleon::Util::Console class defines a console interface that the Nucleon
# framework uses to collect and display information to stdin, stdout, and stderr.
#
# This console interface is inspired by Vagrant's UI system but has some
# important differences.
#
# === Important rule
#
# We split all outbound message traffic between stdout and stderr by routing all
# data dumps to stderr and all other text based messages to stdout (even errors).
#
# TODO: This system will break if other libraries write to stderr.  Eventually
# build multiple messaging systems on top of basic connection.
#
# TODO: Figure out some way to switch to a color profile method instead of current
# color methods.
#
# Remember:
# * *stderr*  Serialized data objects ONLY
# * *stdout*  ALL text messages (debug, info, warnings, and errors)
#
# If you are using this class, you don't have to think about this but it still
# helps to remember.
#
# Primary functions:
#
# 1. Render and transmit messages to various output channels
# 2. Dump data to isolated output channels
# 3. Collect public and private (hidden) information from input channels
# 4. Provide a color format library for composing potentially nested colored strings
#
# See also:
# - Nucleon::Core (base UI capable object)
#
class Console

  #
  # Flush output immediately.
  #
  $stderr.sync = true
  $stdout.sync = true

  #
  # Color formatter map
  #
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

  #
  # Colored message map
  #
  @@color_map = {
    :warn    => :yellow,
    :error   => :red,
    :success => :green
  }

  #*****************************************************************************
  # Constructor

  # Initialize a new console object
  #
  # TODO: Figure out some way to make the console system pluggable?
  #
  # * *Parameters*
  #   - [Hash] *options*  Console options
  #     - [String] *:resource*  Logger resource identifier (also serves as prefix)
  #     - [Boolean] *:color*  Whether or not to render messages in color (overridden by global quiet)
  #     - [Symbol] *:printer*  Printer method (default :puts)
  #     - [IO] *:input*  Don't touch
  #     - [IO] *:output*  Don't touch
  #     - [IO] *:error*  Don't touch
  #     - [ANY] *:console_delegate*  Delegate object that handles console operations (must implement logging interface)
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Config::ensure
  #
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

  # Return a string reference that identifies this console object
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
  # [String]  Console resource name
  #
  # This is the string identifier and default console prefix used when rendering.
  #
  attr_accessor :resource
  #
  # [Boolean]  Whether or not to use color markers when rendering text
  #
  # This can be overridden by the global quiet setting ::quiet, ::quiet=
  #
  attr_accessor :color
  #
  # [IO]  Input IO object
  #
  # Don't touch unless you know what you are doing.
  #
  attr_accessor :input
  #
  # [IO]  Output IO object (messages)
  #
  # Don't touch unless you know what you are doing.
  #
  attr_accessor :output
  #
  # [IO]  Error IO object (data)
  #
  # Don't touch unless you know what you are doing.
  #
  attr_accessor :error
  #
  # [ANY]  Any class that implements this console interface
  #
  attr_accessor :delegate

  #
  # Global quiet flag to disable all output
  #
  @@quiet = false

  # Check current global quiet flag
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Boolean]  Whether or not console output is disabled at the global level
  #
  # * *Errors*
  #
  # See also:
  # - ::quiet=
  #
  def self.quiet
    @@quiet
  end

  # Set current global quiet flag
  #
  # * *Parameters*
  #   - [Boolean] *quiet*  Whether or not console output is disabled at the global level
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - ::quiet
  #
  def self.quiet=quiet
    @@quiet = quiet
  end
#
  # Global flag to render console output in color (using color formatting)
  #
  @@use_colors = true

  # Check current global use colors flag
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Boolean]  Whether or not console output coloring is allowed at the global level
  #
  # * *Errors*
  #
  # See also:
  # - ::use_colors=
  #
  def self.use_colors
    @@use_colors && ! ENV['NUCLEON_NO_COLOR']
  end

  # Set current global use colors flag
  #
  # * *Parameters*
  #   - [Boolean] *use_colors*  Whether or not console output coloring is allowed at the global level
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - ::use_colors
  #
  def self.use_colors=use_colors
    @@use_colors = use_colors
  end

  #*****************************************************************************
  # UI functionality

  # Output via a printer method to an output channel unless quiet specified
  #
  # * *Parameters*
  #   - [Symbol] *type*  Message type; *:warn*, *:error*, *:success*
  #   - [String] *message*  Message to render to output channel
  #   - [Hash] *options*  Output options
  #     - [Boolean] *:quiet_override*  Whether or not to override global quiet flag
  #     - [Boolean] *:new_line*  Append new line to end of message
  #     - [Boolean] *:prefix*  Render prefix before message (console resource)
  #     - [Symbol] *:channel*  IO channel to send output to (don't touch)
  #     - #format_message options
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - #check_delegate
  # - #format_message
  # - #safe_puts
  #
  def say(type, message, options = {})
    return if @@quiet && ! options[:quiet_override]
    return @delegate.say(type, message, options) if check_delegate('say')

    defaults = { :new_line => true, :prefix => true }
    options  = defaults.merge(options)
    printer  = options[:new_line] ? :puts : :print

    puts_options           = { :printer => printer }
    puts_options[:channel] = options[:channel] if options.has_key?(:channel)

    safe_puts(format_message(type, message, options) + "\n", puts_options)
  end

  # Dump an object to an output channel even if quiet specified
  #
  # Data dumps can not be silenced.
  #
  # * *Parameters*
  #   - [String] *data*  Serialized data object or text string
  #   - [Hash] *options*  Dump options
  #     - [Symbol] *:channel*  IO channel to send output to (don't touch)
  #     - #safe_puts options
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - #check_delegate
  # - #safe_puts
  #
  def dump(data, options = {})
    return @delegate.dump(data, options) if check_delegate('dump')

    options[:channel] = options.has_key?(:channel) ? options[:channel] : @error
    safe_puts(data.to_s, options)
  end

  # Ask terminal user for an input value
  #
  # Input text can be freely displayed or hidden as typed.
  #
  # * *Parameters*
  #   - [String] *message*  Message to display to the user
  #   - [Hash] *options*  Input options
  #     - [Boolean] *:new_line*  Append new line to end of message
  #     - [Boolean] *:prefix*  Render prefix before message (console resource)
  #     - [Boolean] *:echo*  Whether or not to echo the input back to the screen
  #     - #say options (minus :quiet_override)
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - #check_delegate
  # - #say
  # - Nucleon::Config::ensure
  # - Nucleon::Config#import
  # - Nucleon::Config#export
  #
  def ask(message, options = {})
    return @delegate.ask(message, options) if check_delegate('ask')

    options[:new_line] = false if ! options.has_key?(:new_line)
    options[:prefix] = false if ! options.has_key?(:prefix)
    options[:echo] = true if ! options.has_key?(:echo)

    user_input = nil

    say(:info, message, Config.ensure(options).import({ :quiet_override => true }).export)

    if options[:echo]
      user_input = @input.gets.chomp
    else
      require 'io/console'
      user_input = @input.noecho(&:gets).chomp
    end
    safe_puts("\n")
    user_input
  end

  # Ask terminal user for a password
  #
  # Keeps requesting until two password inputs match or user cancels the input.
  #
  # TODO: Needs I18n treatment.
  #
  # * *Parameters*
  #   - [String, Symbol] *type*  Type of password being requested (in prompt)
  #   - [Hash] *options*  Input options
  #
  # * *Returns*
  #   - [String]  Returns password with whitespace stripped
  #
  # * *Errors*
  #
  # See also:
  # - #check_delegate
  # - #ask
  #
  def password(type, options = {})
    return @delegate.password(type, options) if check_delegate('password')

    try_again = true
    password  = nil

    while try_again
      # Get and check a password from the keyboard
      password              = ask("Enter #{type} password: ", { :echo => false })
      confirmation_password = ask("Confirm #{type} password: ", { :echo => false })

      if password != confirmation_password
        choice    = ask('Passwords do not match!  Try again? (Y|N): ')
        try_again = choice.upcase == "Y"
        password  = nil unless try_again
      else
        try_again = false
      end
    end
    password.strip
  end

  #*****************************************************************************

  # Output information to an output channel unless quiet specified
  #
  # * *Parameters*
  #   - [String] *message*  Message to render to output channel
  #   - [Hash] *options*  Output options
  #     - #say options
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - #check_delegate
  # - #say
  #
  def info(message, *args)
    return @delegate.info(message, *args) if check_delegate('info')
    say(:info, message, *args)
  end

  # Output warning to an output channel unless quiet specified
  #
  # * *Parameters*
  #   - [String] *message*  Message to render to output channel
  #   - [Hash] *options*  Output options
  #     - #say options
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - #check_delegate
  # - #say
  #
  def warn(message, *args)
    return @delegate.warn(message, *args) if check_delegate('warn')
    say(:warn, message, *args)
  end

  # Output error to an output channel unless quiet specified
  #
  # * *Parameters*
  #   - [String] *message*  Message to render to output channel
  #   - [Hash] *options*  Output options
  #     - #say options
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - #check_delegate
  # - #say
  #
  def error(message, *args)
    return @delegate.error(message, *args) if check_delegate('error')
    say(:error, message, *args)
  end

  # Output success message to an output channel unless quiet specified
  #
  # * *Parameters*
  #   - [String] *message*  Message to render to output channel
  #   - [Hash] *options*  Output options
  #     - #say options
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - #check_delegate
  # - #say
  #
  def success(message, *args)
    return @delegate.success(message, *args) if check_delegate('success')
    say(:success, message, *args)
  end

  #*****************************************************************************
  # Utilities

  # Format a message for display.
  #
  # Primary functions:
  #
  # 1. Add prefix to each line if requested (:prefix)
  # 2. Add colors to each line if requested (global and instance color enabled)
  #
  # * *Parameters*
  #   - [Symbol] *type*  Message type; *:warn*, *:error*, *:success*
  #   - [String] *message*  Message to render
  #   - [Hash] *options*  Format options
  #     - [Boolean] *:color*  Color to use; *:black*, *:red*, *:green*, *:yellow*, *:blue*, *:purple*, *:cyan*, *:grey*
  #     - [Boolean] *:prefix*  Render prefix before message
  #     - [String] *:prefix_text*  Text to render within brackets [{prefix_text}] (default console resource)
  #
  # * *Returns*
  #   - [String]  Formatted string ready for output
  #
  # * *Errors*
  #
  # See also:
  # - ::use_colors
  # - ::colorize
  # - #check_delegate
  # - #say
  #
  def format_message(type, message, options = {})
    return @delegate.format_message(type, message, options) if check_delegate('format_message')
    return '' if message.to_s.strip.empty?

    if options[:prefix]
      if prefix_text = options[:prefix_text]
        prefix = "[#{prefix_text}]"

      elsif @resource && ! @resource.empty?
        prefix = "[#{@resource}]"
      end
    end

    lines         = []
    prev_color    = nil
    escaped_clear = Regexp.escape(@@colors[:clear])

    message.split("\n").each do |line|
      line = prev_color + line if self.class.use_colors && @color && prev_color

      lines << "#{prefix} #{line}".sub(/^ /, '')

      if self.class.use_colors && @color
        # Set next previous color
        if line =~ /#{escaped_clear}$/
          prev_color = nil
        else
          line_section = line.split(/#{escaped_clear}/).pop

          if line_section
            prev_colors = line_section.scan(/\e\[[0-9][0-9]?m/)
            prev_color  = prev_colors.pop unless prev_colors.empty?
          end
        end
      end
    end

    message = lines.join("\n")

    if self.class.use_colors && @color
      if options.has_key?(:color)
        message = self.class.colorize(message, options[:color])
      else
        message = self.class.colorize(message, @@color_map[type]) if @@color_map[type]
      end
    end
    return message
  end

  # Safely output via a printer method to an output channel unless quiet specified
  #
  # * *Parameters*
  #   - [String] *message*  Message to render to output channel
  #   - [Hash] *options*  Output options
  #     - [Symbol] *:channel*  IO channel to send output to (don't touch)
  #     - [Symbol] *:printer*  Printer method to use; *:puts*, *:print*
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #   - [Errno::EPIPE]  Error if sending of output to communication channel fails
  #
  # See also:
  # - #check_delegate
  #
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

  #*****************************************************************************

  # Check if a registered delegate exists and responds to a specified method.
  #
  # * *Parameters*
  #   - [String, Symbol] *method*  Method to check in delegate if registered
  #
  # * *Returns*
  #   - [Boolean]  Whether a delegate that responds to method exists
  #
  # * *Errors*
  #
  def check_delegate(method)
    return Util::Data.test(@delegate && @delegate.respond_to?(method.to_s))
  end

  #*****************************************************************************
  # Color translation

  # Colorize a given string if global colors enabled, else return input string.
  #
  # * *Parameters*
  #   - [String, Symbol] *string*  String to colorize (if colors allowed globally)
  #   - [String, Symbol] *color*  Color to use; *:black*, *:red*, *:green*, *:yellow*, *:blue*, *:purple*, *:cyan*, *:grey*
  #
  # * *Returns*
  #   - [String]  Colorized or input string depending on global color flag
  #
  # * *Errors*
  #
  # See also:
  # - ::use_colors
  #
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

  # Color a given string black if global colors enabled, else return input string.
  #
  # * *Parameters*
  #   - [String, Symbol] *string*  String to colorize (if colors allowed globally)
  #
  # * *Returns*
  #   - [String]  Black or uncolored input string depending on global color flag
  #
  # * *Errors*
  #
  # See:
  # - ::colorize
  #
  def self.black(string)
    colorize(string, :black)
  end

  # Color a given string red if global colors enabled, else return input string.
  #
  # * *Parameters*
  #   - [String, Symbol] *string*  String to colorize (if colors allowed globally)
  #
  # * *Returns*
  #   - [String]  Red or uncolored input string depending on global color flag
  #
  # * *Errors*
  #
  # See:
  # - ::colorize
  #
  def self.red(string)
    colorize(string, :red)
  end

  # Color a given string green if global colors enabled, else return input string.
  #
  # * *Parameters*
  #   - [String, Symbol] *string*  String to colorize (if colors allowed globally)
  #
  # * *Returns*
  #   - [String]  Green or uncolored input string depending on global color flag
  #
  # * *Errors*
  #
  # See:
  # - ::colorize
  #
  def self.green(string)
    colorize(string, :green)
  end

  # Color a given string yellow if global colors enabled, else return input string.
  #
  # * *Parameters*
  #   - [String, Symbol] *string*  String to colorize (if colors allowed globally)
  #
  # * *Returns*
  #   - [String]  Yellow or uncolored input string depending on global color flag
  #
  # * *Errors*
  #
  # See:
  # - ::colorize
  #
  def self.yellow(string)
    colorize(string, :yellow)
  end

  # Color a given string blue if global colors enabled, else return input string.
  #
  # * *Parameters*
  #   - [String, Symbol] *string*  String to colorize (if colors allowed globally)
  #
  # * *Returns*
  #   - [String]  Blue or uncolored input string depending on global color flag
  #
  # * *Errors*
  #
  # See:
  # - ::colorize
  #
  def self.blue(string)
    colorize(string, :blue)
  end

  # Color a given string purple if global colors enabled, else return input string.
  #
  # * *Parameters*
  #   - [String, Symbol] *string*  String to colorize (if colors allowed globally)
  #
  # * *Returns*
  #   - [String]  Purple or uncolored input string depending on global color flag
  #
  # * *Errors*
  #
  # See:
  # - ::colorize
  #
  def self.purple(string)
    colorize(string, :purple)
  end

  # Color a given string cyan if global colors enabled, else return input string.
  #
  # * *Parameters*
  #   - [String, Symbol] *string*  String to colorize (if colors allowed globally)
  #
  # * *Returns*
  #   - [String]  Cyan or uncolored input string depending on global color flag
  #
  # * *Errors*
  #
  # See:
  # - ::colorize
  #
  def self.cyan(string)
    colorize(string, :cyan)
  end

  # Color a given string grey if global colors enabled, else return input string.
  #
  # * *Parameters*
  #   - [String, Symbol] *string*  String to colorize (if colors allowed globally)
  #
  # * *Returns*
  #   - [String]  Grey or uncolored input string depending on global color flag
  #
  # * *Errors*
  #
  # See:
  # - ::colorize
  #
  def self.grey(string)
    colorize(string, :grey)
  end
end
end
end
