
#*******************************************************************************
# Nucleon
#
# Framework that provides a simple foundation for building distributively 
# configured, extremely pluggable and extendable, and easily parallel 
# applications.
#
# Author::    Adrian Webb (mailto:adrian.webb@coralnexus.com)
# License::   GPLv3

#-------------------------------------------------------------------------------
# Global namespace

module Kernel
   
  def dbg(data, label = '')
    # Invocations of this function should NOT be committed to the project
    require 'pp'
    
    puts '>>----------------------'
    unless ! label || label.empty?
      puts label
      puts '---'
    end
    pp data
    puts '<<'
  end
  
  #---  
    
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
    
  #---
  
  def nucleon_require(base_dir, name)
    name = name.to_s
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

#-------------------------------------------------------------------------------
# Load paths 

lib_dir          = File.dirname(__FILE__)
core_dir         = File.join(lib_dir, 'core')
mixin_dir        = File.join(core_dir, 'mixin')
mixin_config_dir = File.join(mixin_dir, 'config')
mixin_action_dir = File.join(mixin_dir, 'action')
macro_dir        = File.join(mixin_dir, 'macro')
util_dir         = File.join(core_dir, 'util')
mod_dir          = File.join(core_dir, 'mod')
plugin_dir       = File.join(core_dir, 'plugin')

#-------------------------------------------------------------------------------
# Environment checks and debugging

module Nucleon
  
  def self.VERSION
    File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))  
  end
 
  #-----------------------------------------------------------------------------
  
  def self.debugging?
    ENV["NUCLEON_DEBUG"] ? true : false  
  end
  
  #---
  
  def self.debug_break(condition = true)
    if debugging?
      # Pry debug handler
      binding.pry if condition
    end  
  end
  
  #-----------------------------------------------------------------------------
  
  def self.parallel?
    debugging? || ENV['NUCLEON_NO_PARALLEL'] ? false : true
  end  
end
  
#-------------------------------------------------------------------------------
# Coral requirements

$:.unshift(lib_dir) unless $:.include?(lib_dir) || $:.include?(File.expand_path(lib_dir))

#---

if Nucleon.debugging?
  require 'pry'
  require 'pry-stack_explorer'
  require 'pry-debugger'

  if defined?(PryDebugger)
    Pry.commands.alias_command 'c', 'continue'
    Pry.commands.alias_command 's', 'step'
    Pry.commands.alias_command 'n', 'next'
    Pry.commands.alias_command 'f', 'finish'
  end 
end

#---

# TODO: Reduce the number of dependencies loaded in this load script (for performance).
# Decentralize!

require 'optparse'
require 'i18n'
require 'log4r'
require 'log4r/configurator'
require 'deep_merge'

require 'digest/sha1'
require 'base64'

require 'yaml'
require 'multi_json'

require 'tmpdir'
require 'sshkey'

require 'childprocess'
require 'thread'

if Nucleon.parallel?
  require 'celluloid'
  require 'celluloid/autostart'  
end

#---

# TODO: Make this dynamically settable

I18n.enforce_available_locales = false
I18n.load_path << File.expand_path(File.join('..', 'locales', 'en.yml'), lib_dir)

#---

# Make sure logger is at the top of our load order priorities
nucleon_require(util_dir, :logger)

#---

# Object modifications (100% pure monkey patches)
Dir.glob(File.join(mod_dir, '*.rb')).each do |file|
  require file
end

#---

# Mixins for classes
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

#---

nucleon_require(core_dir, :facade)

module Nucleon
  extend Facade
end

#---

# Include bootstrap classes
nucleon_require(core_dir, :errors)
nucleon_require(core_dir, :codes)
nucleon_require(util_dir, :data)
nucleon_require(core_dir, :config)
nucleon_require(util_dir, :console) 
nucleon_require(core_dir, :core) 

#---

# Include core utilities
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

#---

if nucleon_locate('git')
  require 'rugged'
  nucleon_require(util_dir, :git)
end

#---

# Include plugin system
#nucleon_require(core_dir, :facade)
nucleon_require(core_dir, :gems)
nucleon_require(core_dir, :manager)
nucleon_require(plugin_dir, :base)
nucleon_require(core_dir, :plugin)
