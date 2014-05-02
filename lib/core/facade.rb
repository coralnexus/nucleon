
module Nucleon
#-------------------------------------------------------------------------------
# Parallel interface (include Parallel)

module Parallel
  
  def self.included(klass)
    if Nucleon.parallel?
      klass.send :include, Celluloid      
    end
    klass.send :include, InstanceMethods
    klass.extend ClassMethods
  end
  
  #---
  
  module InstanceMethods
    def parallel(method, split_args, *shared_args)
      results    = []
      split_args = [ split_args ] unless split_args.is_a?(Array)
  
      if Nucleon.parallel?
        split_args.each do |arg|
          results << future.send(method, arg, *shared_args)
        end
        results.map { |future| future.value } # Wait for all to finish.
      else
        split_args.each do |arg|
          results << send(method, arg, *shared_args)
        end  
      end
      results
    end
  end
  
  #---

  module ClassMethods
    def external_block_exec(*methods)
      if Nucleon.parallel?
        methods.each do |method|
          execute_block_on_receiver method.to_sym
        end
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Core Nucleon facade (extend Facade)
  
module Facade
 
  include Mixin::Colors
  
  #-----------------------------------------------------------------------------
 
  def ui
    Core.ui
  end
  
  def ui_group(resource, color = :cyan, &code)
    Core.ui_group(resource, color, &code)
  end
  
  def quiet=quiet
    Util::Console.quiet = quiet  
  end
  
  #---
  
  def logger
    Core.logger
  end
  
  def log_level
    Util::Logger.level
  end
  
  def log_level=log_level
    Util::Logger.level = log_level
  end
  
  #-----------------------------------------------------------------------------
  
  def handle(klass)
    if parallel? && klass.respond_to?(:current_actor)
      myself = klass.current_actor
    else
      myself = klass
    end
    myself
  end
  
  #---
  
  def manager(collection, name, klass)
    name = name.to_sym
    
    if collection.has_key?(name)
      manager = collection[name]
    else
      if parallel?
        klass.supervise_as name
        manager = Celluloid::Actor[name]
      else
        manager = klass.new # Managers should not have initialization parameters
      end
      collection[name] = manager
    end
    test_connection(manager)
    manager
  end
  
  def test_connection(manager)
    if parallel?
      begin
        # Raise error if no test method found but retry for dead actors
        manager.test_connection
      rescue Celluloid::DeadActorError
        retry
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  
  def admin?
    is_admin  = ( ENV['USER'] == 'root' )
    ext_admin = exec(:check_admin) do |op, results|
      if op == :reduce
        results.values.include?(true)
      else
        results ? true : false
      end
    end
    is_admin || ext_admin ? true : false
  end
  
  #---
  
  @@ip_cache = nil
  
  def ip_address(reset = false)
    external_ip    = nil
    cached_ip_file = File.join(Dir.tmpdir(), 'nucleon_ip.json')
    
    unless @@ip_cache      
      json_text  = Util::Data.ensure_value(Util::Disk.read(cached_ip_file), '')
      @@ip_cache = Util::Data.parse_json(json_text) unless json_text.empty?
    end
        
    fetch_ip = lambda do
      result     = cli_run(value(:external_address_command, 'curl --silent ifconfig.me'), { :quiet => true })
      ip_address = result.output
      
      unless ip_address.empty?
        @@ip_cache = {
          'ip'      => ip_address,
          'updated' => Time.new.to_s
        }
        Util::Disk.write(cached_ip_file, Util::Data.to_json(@@ip_cache))
      end
      ip_address
    end
        
    if reset || (! @@ip_cache || @@ip_cache.empty? || ! @@ip_cache.has_key?('ip'))
      external_ip = fetch_ip.call
    else
      external_ip    = @@ip_cache['ip']
      updated_time   = Time.parse(@@ip_cache['updated'])
      cache_duration = (Time.new - updated_time) / 60 # Seconds to minutes
      
      if cache_duration >= value(:external_address_lifetime, 60)
        external_ip = fetch_ip.call
      end
    end
    external_ip
  end
  
  #-----------------------------------------------------------------------------
  # Status codes
  
  def code
    Codes.new
  end
  
  def codes(*codes)
    Codes.codes(*codes)
  end
  
  #-----------------------------------------------------------------------------
  # Core plugin interface
  
  def reload(core = false, &code)
    Manager.connection.reload(core, &code)  
  end
  
  #---
  
  def namespaces
    Manager.connection.namespaces
  end
  
  def define_namespace(*namespaces)
    Manager.connection.namespace(*namespaces) 
  end
  
  #---
  
  def types
    Manager.connection.types
  end
  
  def define_type(type_info)
    Manager.connection.define_type(type_info)
  end
   
  def type_default(type)
    Manager.connection.type_default(type)
  end
  
  #---
  
  def register(base_path, &code)
    Manager.connection.register(base_path, &code)
    Manager.connection.autoload
  end
  
  def loaded_plugins(type = nil, provider = nil)
    Manager.connection.loaded_plugins(type, provider)    
  end
  
  #---
  
  def active_plugins(type = nil, provider = nil)
    Manager.connection.plugins(type, provider)    
  end
  
  #---
  
  def plugin(type, provider, options = {})
    Manager.connection.load(type, provider, options)
  end
  
  #---
  
  def plugins(type, data, build_hash = false, keep_array = false)
    Manager.connection.load_multiple(type, data, build_hash, keep_array)
  end
  
  #---
  
  def create_plugin(type, provider, options = {})
    Manager.connection.create(type, provider, options)
  end
  
  #---
  
  def get_plugin(type, name)
    Manager.connection.get(type, name)
  end
  
  #---
  
  def remove_plugin(plugin)
    Manager.connection.remove(plugin)
  end
  
  #---
  
  def plugin_class(type)
    Manager.connection.plugin_class(type)
  end
  
  #---
  
  def provider_class(namespace, type, provider)
    Manager.connection.provider_class(namespace, type, provider)  
  end
    
  #-----------------------------------------------------------------------------
  # Core plugin type facade
  
  def extension(provider)
    plugin(:extension, provider, {})
  end
  
  #---
  
  def action(provider, options)
    plugin(:action, provider, options)
  end
  
  def actions(data, build_hash = false, keep_array = false)
    plugins(:action, data, build_hash, keep_array)  
  end
  
  def action_config(provider)
    action = action(provider, { :settings => {}, :quiet => true })
    return {} unless action
    
    action.configure
    action.config
  end
  
  def action_run(provider, options = {}, quiet = true)
    Plugin::Action.exec(provider, options, quiet)
  end
  
  def action_cli(provider, args = [], quiet = false, name = :nucleon)
    Plugin::Action.exec_cli(provider, args, quiet, name)
  end
  
  #---
  
  def project(options, provider = nil)
    plugin(:project, provider, options)
  end
  
  def projects(data, build_hash = false, keep_array = false)
    plugins(:project, data, build_hash, keep_array)
  end
   
  #-----------------------------------------------------------------------------
  # Utility plugin type facade
  
  def command(options, provider = nil)
    plugin(:command, provider, options)
  end
  
  def commands(data, build_hash = false, keep_array = false)
    plugins(:command, data, build_hash, keep_array)
  end
   
  #---
  
  def event(options, provider = nil)
    plugin(:event, provider, options)
  end
  
  def events(data, build_hash = false, keep_array = false)
    plugins(:event, data, build_hash, keep_array)
  end
  
  #---
  
  def template(options, provider = nil)
    plugin(:template, provider, options)
  end
  
  def templates(data, build_hash = false, keep_array = false)
    plugins(:template, data, build_hash, keep_array)
  end
   
  #---
  
  def translator(options, provider = nil)
    plugin(:translator, provider, options)
  end
  
  def translators(data, build_hash = false, keep_array = false)
    plugins(:translator, data, build_hash, keep_array)
  end
  
  #-----------------------------------------------------------------------------
  # Plugin extensions
   
  def exec(method, options = {}, &code)
    Manager.connection.exec(method, options, &code)
  end
  
  #---
  
  def config(type, options = {})
    Manager.connection.config(type, options)
  end
  
  #---
  
  def check(method, options = {})
    Manager.connection.check(method, options)
  end
  
  #---
  
  def value(method, value, options = {})
    Manager.connection.value(method, value, options)
  end
  
  #---
  
  def collect(method, options = {})
    Manager.connection.collect(method, options)
  end
        
  #-----------------------------------------------------------------------------
  # External execution
   
  def run
    begin
      logger.debug("Running contained process at #{Time.now}")
      yield
      
    rescue Exception => error
      logger.error("Nucleon run experienced an error! Details:")
      logger.error(error.inspect)
      logger.error(error.message)
      logger.error(Util::Data.to_yaml(error.backtrace))
  
      ui.error(error.message) if error.message
      raise
    end
  end
  
  #---
    
  def cli_run(command, options = {}, &code)
    command = command.join(' ') if command.is_a?(Array)
    config  = Config.ensure(options)
    
    logger.info("Executing command #{command}")
        
    result = Util::Shell.connection.exec(command, config, &code)
    
    unless config.get(:quiet, false) || result.status == Nucleon.code.success
      ui.error("Command #{command} failed to execute")
    end     
    result
  end
  
  #---
  
  def executable(args, name = 'nucleon') #ARGV
    Signal.trap("INT") { exit 1 }

    logger.info("`#{name}` invoked: #{args.inspect}")

    $stdout.sync = true
    $stderr.sync = true
    
    exit_status = nil

    begin
      logger.debug("Beginning execution run")
      
      arg_components = Util::CLI::Parser.split(args, "#{name} <action> [ <arg> ... ]")
      main_command   = arg_components.shift
      sub_command    = arg_components.shift
      sub_args       = arg_components
      
      lib_dir = File.join(Dir.pwd, 'lib')
      if File.directory?(lib_dir)
        logger.debug("Registering plugins at #{lib_dir}")
        Nucleon.register(lib_dir)
      end
            
      if main_command.processed && sub_command
        exit_status = action_cli(sub_command, sub_args, false, name)
      else
        puts I18n.t('nucleon.core.exec.help.usage') + ': ' + main_command.help + "\n"
        puts I18n.t('nucleon.core.exec.help.header') + ":\n\n"
        
        help_data     = {}
        extended_help = main_command.options[:extended_help]
        
        loaded_plugins(:action).each do |provider, data|
          namespace = data[:namespace]
          
          help_data[namespace]           = {} unless help_data.has_key?(namespace)
          help_data[namespace][provider] = data
        end
        
        help_data.each do |namespace, actions|
          actions.each do |provider, data|
            if extended_help
              help_text = action(provider, { :args => [ '-h' ], :quiet => true }).help  
            else
              help_text = action(provider, { :settings => {}, :quiet => true }).help   
            end
            puts sprintf("   %-15s : %s\n", namespace, help_text)  
          end
          puts "\n"
        end
    
        puts "\n" + I18n.t('nucleon.core.exec.help.footer', { :name => name }) + "\n\n"   
        exit_status = code.help_wanted  
      end 
  
    rescue Exception => error
      logger.error("Nucleon executable experienced an error:")
      logger.error(error.inspect)
      logger.error(error.message)
      logger.error(Util::Data.to_yaml(error.backtrace))

      ui.error(error.message, { :prefix => false }) if error.message
  
      exit_status = error.status_code if error.respond_to?(:status_code)
      exit_status = code.unknown_status if exit_status.nil?
    end
    exit_status
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def class_name(name, separator = '::', want_array = false)
    Manager.connection.class_name(name, separator, want_array)
  end
  
  #---
  
  def class_const(name, separator = '::')
    Manager.connection.class_const(name, separator)
  end
  
  #---
  
  def sha1(data)
    Digest::SHA1.hexdigest(Util::Data.to_json(data, false))
  end
  
  #---
  
  def silence
    result = nil
    
    begin
      orig_stderr = $stderr.clone
      orig_stdout = $stdout.clone
      $stderr.reopen File.new('/dev/null', 'w')
      $stdout.reopen File.new('/dev/null', 'w')
      
      result = yield
    
    rescue Exception => error
      $stdout.reopen orig_stdout
      $stderr.reopen orig_stderr
      raise error
    ensure
      $stdout.reopen orig_stdout
      $stderr.reopen orig_stderr
    end
    result
  end
  
  #---
  
  def render_object(data)
    require 'pp'
    PP.pp(data, "").strip
  end  
end
end

