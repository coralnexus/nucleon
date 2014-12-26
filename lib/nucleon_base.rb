#
# == Nucleon
#
# Framework that provides a simple foundation for building distributed,
# pluggable, and integrated applications.
#
# Author::    Adrian Webb (mailto:adrian.webb@coralnexus.com)
# License::   Apache License, version 2


#*******************************************************************************
# Global namespace

# Kernel module additions
#
# These methods, all of which are prefixed with "nucleon_" are available in any
# class or module within the Nucleon framework or derivatives.
#
module Kernel

  # Locate an application command or return nil otherwise.
  #
  # This is used to check for applications, such as Git, so that we may
  # conditionally install packages based upon applications installed.
  #
  # * *Parameters*
  #   - [String, Symbol] *command*  Command name to locale on system
  #
  # * *Returns*
  #   - [nil, String]  File path to executable or nil if not found
  #
  # * *Errors*
  #
  def nucleon_locate(command)
    command = command.to_s
    exts    = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{command}#{ext}")
        return exe if File.executable?(exe)
      end
    end
    return nil
  end

  # Require resource files into Nucleon execution flow.
  #
  # This method auto-requires resources in the following order:
  #
  # 1. *{name}.rb*
  # 2. *{base_dir/name}/**/*.rb
  #
  # If resources within the directory depend on each other those requires should
  # be present in the resource files doing the requiring so we don't get load
  # order conflicts.
  #
  # * *Parameters*
  #   - [String, Symbol] *base_dir*  Command name to locale on system
  #   - [String, Symbol] *name*  Command name to locale on system
  #
  # * *Returns*
  #   - [Void]  This method does not have a return value
  #
  # * *Errors*
  #
  def nucleon_require(base_dir, name)
    base_dir       = base_dir.to_s
    name           = name.to_s
    top_level_file = File.join(base_dir, "#{name}.rb")

    require top_level_file if File.exists?(top_level_file)

    directory = File.join(base_dir, name)

    if File.directory?(directory)
      Dir.glob(File.join(directory, '**', '*.rb')).each do |sub_file|
        require sub_file
      end
    end
  end
end

#*******************************************************************************
# Load paths

#
# The following variables refer to Nucleon file load paths loaded during
# initialization.
#

#
# Base library path
#
lib_dir = File.dirname(__FILE__)
#
# Core class load path
#
core_dir = File.join(lib_dir, 'core')
#
# Base mixin load path
#
mixin_dir = File.join(core_dir, 'mixin')
#
# Configuration mixin load path
#
mixin_config_dir = File.join(mixin_dir, 'config')
#
# Action mixin load path
#
mixin_action_dir = File.join(mixin_dir, 'action')
#
# Macro mixin load path
#
macro_dir = File.join(mixin_dir, 'macro')
#
# Utilities load path
#
util_dir = File.join(core_dir, 'util')
#
# Mod load path (monkey patches)
#
mod_dir = File.join(core_dir, 'mod')
#
# Base plugin load path
#
plugin_dir = File.join(core_dir, 'plugin')

#*******************************************************************************
# Environment checks and debugging

# Nucleon top level module
#
# Any methods contained in this file are purely for enabling early checks or
# operations needed for loading Nucleon effectively?
#
# Most methods to the Nucleon module should be loaded via the Nucleon::Facade.
#
module Nucleon

  # Get currently loaded versioin of Nucleon
  #
  # This method loads from the VERSION file in the top level directory.  This file
  # gets automatically updated as we build and release new versions.
  #
  # See the Rakefile and the Coral Toolbox project at:
  #
  # http://github.com/coralnexus/coral-toolbox
  #
  # *Note*: This process might change in the near future.
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [String]  Currently loaded version of Nucleon framework
  #
  # * *Errors*
  #
  def self.VERSION
    File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))
  end

  #*****************************************************************************

  #
  # Global flag that indicate whether or not dumping with dbg() is active
  #
  # Think of this as a global on/off switch in case dbg() statements are
  # accidentally left in code.
  #
  @@dump_enabled = false

  # Enable or disable variable dumping through dbg()
  #
  # * *Parameters*
  #   - [Boolean] *dump*  Whether or not to enable dumping through dbg()
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - ::dump_enabled
  #
  def self.dump_enabled=dump
    @@dump_enabled = dump
  end

  # Check whether dumping is enabled or disabled through dbg()
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Boolean]  Whether or not to enable dumping through dbg()
  #
  # * *Errors*
  #
  # See also:
  # - ::dump_enabled=
  #
  def self.dump_enabled
    @@dump_enabled
  end

  #*****************************************************************************

  # Check if debugging is enabled
  #
  # This uses the environment variable *"NUCLEON_DEBUG"*
  #
  #   ENV["NUCLEON_DEBUG"]
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Boolean]  Whether or not debugging is enabled
  #
  # * *Errors*
  #
  # See also:
  # - ::debug_break
  #
  def self.debugging?
    ENV["NUCLEON_DEBUG"] ? true : false
  end

  # Set a debug break poing at the line of invocation if debugging is enabled.
  #
  # Nucleon uses Pry to perform stepwise debugging through the code.
  #
  # Note: This is not used very often so it may be buggy in areas.
  #
  # * *Parameters*
  #   - [Boolean] *condition*  Boolean test to check if the debugging breakpoint should be active
  #
  # * *Returns*
  #   - [Void]  This method does not return a value
  #
  # * *Errors*
  #
  # See also:
  # - ::debugging?
  #
  def self.debug_break(condition = true)
    if debugging?
#*******************************************************************************
# Nucleon Pry powered development console
#
# Usage:
#
# * Execute nucleon (or derivative executable, ex; corl) with the NUCLEON_DEBUG
#   environment variable set
#
#   :> [ sudo ] NUCLEON_DEBUG=1 nucleon <args>...
#
# * Call the debug_break method anywhere in the code to start a debugging
#   session.
#
#   :> Nucleon.debug_break   or    :> Nucleon.debug_break <test?>
#
# * Since the debugging tools don't work in parallel, parallel operations are
#   serialized when NUCLEON_DEBUG environment variable is found.
#
#*******************************************************************************
# General information
#
# For more information on Pry: http://pryrepl.org
#                              ( https://github.com/pry/pry )
#
# Loaded plugins: stack explorer ( https://github.com/pry/pry-stack_explorer )
#                 debugger       ( https://github.com/nixme/pry-debugger )
#
# For available commands and help information: [ help ]
# For command specific help:                   [ <command> --help ]
#
#*******************************************************************************
# General commands:
#
# :> cd <Class>                Change to inspect class (class constant)
# :> show-method <method>      Show source for class method
# :> .<CLI command> <args>...  Execute a CLI command (always starts with dot)
#
#*******************************************************************************
# Breakpoints
#
# :> breakpoints                             List all defined breakpoints
# :> break                                   Same as breakpoints command
#
# :> break <Class>#<method>                  Break at start of `Class#method`.
# :> break <Class>#<method> if <test?>       Break at `Class#method` if `test?`.
# :> break <path>/<ruby file>:<line>         Break at line in ruby file.
# :> break <line>                            Break at line in current file.
#
# :> break --condition <breakpoint> <test?>  Change condition on breakpoint.
# :> break --condition <breakpoint>          Remove condition on breakpoint.
#
# :> break --delete <breakpoint>             Delete breakpoint.
# :> break --disable-all                     Disable all breakpoints.
#
# :> break --show <breakpoint>               Show details about breakpoint.
#
#*******************************************************************************
# Stack inspection / traversal
#
# :> show-stack      Show all accessible frames in the call stack.
# :> frame <number>  Move to a specific frame.
# :> up              Move up one frame in the call stack.
# :> down            Move down one frame in the call stack.
#
#*******************************************************************************
# Debugging execution flow:
#
# :> s = [ step | step <times> ]  Step execution into the next line or method.
# :> n = [ next | next <times> ]  Step over to the next line within same frame.
# :> f = [ finish ]               Execute until current stack frame returns.
# :> c = [ continue ]             Continue program execution (end Pry session).
#
      binding.pry if condition
    end
  end

  #*****************************************************************************

  #
  # Check for no-parallel flag early so we can avoid loading unncessary
  # libraries.  In case we are coming in through the CLI.
  #
  ARGV.each do |arg|
    if arg == '--no-parallel'
      ENV['NUCLEON_NO_PARALLEL'] = '1'
      break
    end
  end

  # Check if parallel execution is enabled
  #
  # This uses the environment variable *"NUCLEON_NO_PARALLEL"*.  Parallelism is
  # enabled by default.
  #
  #   ENV["NUCLEON_NO_PARALLEL"]
  #
  # Due to the complications with parallel debugging, parallel is suspended
  # when debugging is enabled
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Boolean]  Whether or not parallel is enabled
  #
  # * *Errors*
  #
  # See also:
  # - ::debugging?
  #
  def self.parallel?
    debugging? || ENV['NUCLEON_NO_PARALLEL'] ? false : true
  end

  #
  # Global console Mutex lock
  #
  # TODO: This may not be needed?
  #
  @@console_lock = Mutex.new

  # Get the global console Mutex for synchronized console operations.
  #
  # * *Parameters*
  #
  # * *Returns*
  #   - [Mutex]  Console Mutex object
  #
  # * *Errors*
  #
  def self.console_lock
    @@console_lock
  end
end

#*******************************************************************************

#
# We also define a generic debug dump method that is available in any Nucleon
# derived class or module.
#
module Kernel

  # Dump data to the console with optional label.
  #
  # This must be defined under the definition of Nucleon::dump_enabled
  #
  # * *Parameters*
  #   - [ANY] *data*  Data to dump to the console
  #   - [String] *label*  Label to render above data dump
  #   - [Boolean] *override_enabled*  Whether or not to override override Nucleon::dump_enabled
  #
  # * *Returns*
  #   - [Void]  This method does not have a return value
  #
  # * *Errors*
  #
  def dbg(data, label = '', override_enabled = false)
    # Invocations of this function should NOT be committed to the project
    if Nucleon.dump_enabled || override_enabled
      require 'pp'
      puts '>>----------------------'
      unless ! label || label.empty?
        puts label
        puts '---'
      end
      pp data
      puts '<<'
    end
  end
end

#*******************************************************************************
# Coral requirements

#
# Initialize Gem load path
#
$:.unshift(lib_dir) unless $:.include?(lib_dir) || $:.include?(File.expand_path(lib_dir))

#
# Only require debugging packages if debugging is enabled
#
if Nucleon.debugging?
  require 'pry'
  require 'pry-stack_explorer'
  require 'pry-byebug'

  if defined?(PryDebugger)
    Pry.commands.alias_command 'c', 'continue'
    Pry.commands.alias_command 's', 'step'
    Pry.commands.alias_command 'n', 'next'
    Pry.commands.alias_command 'f', 'finish'
  end
end

#
# General requirements
#
# TODO: Reduce the number of dependencies loaded in this load script (for performance).
# Decentralize!

#
# Allows us to work with Gem objects
#
# See:
# - Nucleon::Gems
#
require 'rubygems'
#
# Basic CLI option parsing
#
require 'optparse'
#
# Internationalization
#
require 'i18n'
#
# Logging capabilities
#
require 'log4r'
require 'log4r/configurator'
#
# Data merging
#
require 'deep_merge'
#
# SHA1 identification
#
require 'digest/sha1'
#
# Object serialization
#
require 'base64'
#
# YAML parsing / generation
#
require 'yaml'
#
# JSON parsing / generation
#
require 'multi_json'
#
# Temp directory access
#
require 'tmpdir'
#
# SSH private / public key access and generation
#
require 'sshkey'
#
# Sub process execution
#
require 'childprocess'
#
# Basic threading
#
require 'thread'
#
# Celluloid actors
#
if Nucleon.parallel?
  require 'celluloid'
  require 'celluloid/autostart'
end

#
# I18n settings
#
# TODO: Make this dynamically settable
#
I18n.enforce_available_locales = false
I18n.load_path << File.expand_path(File.join('..', 'locales', 'en.yml'), lib_dir)

#
# Logger
#
# *IMPORTANT*  Make sure logger is at the top of our load order priorities
#
nucleon_require(util_dir, :logger)

#
# Object modifications (100% pure monkey patches)
#
Dir.glob(File.join(mod_dir, '*.rb')).each do |file|
  require file
end

#
# Class mixins
#
Dir.glob(File.join(mixin_dir, '*.rb')).each do |file|
  require file
end
Dir.glob(File.join(mixin_config_dir, '*.rb')).each do |file|
  require file
end
Dir.glob(File.join(mixin_action_dir, '*.rb')).each do |file|
  require file
end
Dir.glob(File.join(macro_dir, '*.rb')).each do |file|
  require file
end

#
# Nucleon facade
#
nucleon_require(core_dir, :facade)

#
# Nucleon::Facade extends Nucleon
#
module Nucleon
  extend Facade
end

#
# Bootstrap classes
#
nucleon_require(core_dir, :errors)
nucleon_require(core_dir, :codes)
nucleon_require(util_dir, :data)
nucleon_require(core_dir, :config)
nucleon_require(util_dir, :console)
nucleon_require(core_dir, :core)

#
# Core utilities
#
[ :liquid,
  :cli,
  :disk,
  :package,
  :cache,
  :shell,
  :ssh
].each do |name|
  nucleon_require(util_dir, name)
end

#
# Git (if it exists on the system)
#
if nucleon_locate('git')
  require 'rugged'
  nucleon_require(util_dir, :git)
end

#
# Nucleon plugin system
#
nucleon_require(core_dir, :gems)
nucleon_require(core_dir, :environment)
nucleon_require(core_dir, :manager)
nucleon_require(plugin_dir, :base)
nucleon_require(core_dir, :plugin)
