
module Nucleon
#-------------------------------------------------------------------------------
# Parallel interface (include Parallel)

module Parallel
  
  def self.included(klass)
    if Nucleon.parallel?
      klass.send :include, Celluloid
      klass.finalizer :parallel_finalize      
    end    
    klass.send :include, InstanceMethods
    klass.extend ClassMethods
  end
  
  #---
  
  module InstanceMethods
    def parallel_finalize
      # Override if needed  
    end
    
    #---
    
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
  
  def manager(collection, name, klass, reset = false)
    name     = name.to_sym
    actor_id = "#{klass}::#{name}".to_sym
        
    if collection.has_key?(actor_id)
      manager = parallel? ? Celluloid::Actor[actor_id] : collection[actor_id]
    else
      if parallel?
        klass.supervise_as(actor_id, actor_id, reset)
        manager = Celluloid::Actor[actor_id]
      else
        manager = klass.new(actor_id, reset) # Managers should have standardized initialization parameters
      end
      collection[actor_id] = manager
    end
    test_connection(actor_id, manager)
  end
  
  def test_connection(actor_id, manager)
    if parallel?
      begin
        # Raise error if no test method found but retry for dead actors
        manager.test_connection
        
      rescue Celluloid::DeadActorError
        retry
      end
    end
    manager
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
  
  #---
  
  def types(namespace)
    Manager.connection.types(namespace)
  end
  
  def define_types(namespace, type_info)
    Manager.connection.define_types(namespace, type_info)
  end
   
  def type_default(namespace, plugin_type)
    Manager.connection.type_default(namespace, plugin_type)
  end
  
  #---
  
  def load_plugins(base_dir = nil)
    base_dir = base_dir.nil? ? Dir.pwd : base_dir
    
    search_plugins = lambda do |search_dir|
      lib_dir = File.join(search_dir, 'lib')
      
      if File.directory?(lib_dir)
        logger.debug("Registering plugins at #{lib_dir}")
        register(lib_dir)
      end
      
      parent_search_dir = search_dir.sub(/#{File::SEPARATOR}[^#{File::SEPARATOR}]+$/, '')
      search_plugins.call(parent_search_dir) unless parent_search_dir.split(File::SEPARATOR).empty?
    end
    
    search_plugins.call(base_dir)
  end
  
  def register(base_path, &code)
    Manager.connection.register(base_path, &code)
    Manager.connection.autoload
  end
  
  def loaded_plugins(namespace = nil, plugin_type = nil, provider = nil)
    Manager.connection.loaded_plugins(namespace, plugin_type, provider)    
  end
  
  #---
  
  def active_plugins(namespace = nil, plugin_type = nil, provider = nil)
    Manager.connection.active_plugins(namespace, plugin_type, provider)    
  end
  
  #---
  
  def plugin(namespace, plugin_type, provider, options = {})
    Manager.connection.load(namespace, plugin_type, provider, options)
  end
  
  #---
  
  def plugins(namespace, plugin_type, data, build_hash = false, keep_array = false)
    Manager.connection.load_multiple(namespace, plugin_type, data, build_hash, keep_array)
  end
  
  #---
  
  def create_plugin(namespace, plugin_type, provider, options = {})
    Manager.connection.create(namespace, plugin_type, provider, options)
  end
  
  #---
  
  def get_plugin(namespace, plugin_type, plugin_name)
    Manager.connection.get(namespace, plugin_type, plugin_name)
  end
  
  #---
  
  def remove_plugin_by_name(namespace, plugin_type, plugin_instance_name)
    Manager.connection.remove_by_name(namespace, plugin_type, plugin_instance_name)  
  end
  
  def remove_plugin(plugin)
    Manager.connection.remove(plugin)
  end
  
  #---
  
  def plugin_class(namespace, plugin_type)
    Manager.connection.plugin_class(namespace, plugin_type)
  end
    
  #-----------------------------------------------------------------------------
  # Core plugin type facade
  
  def extension(provider)
    plugin(:nucleon, :extension, provider, {})
  end
  
  #---
  
  def action(provider, options)
    plugin(:nucleon, :action, provider, options)
  end
  
  def actions(data, build_hash = false, keep_array = false)
    plugins(:nucleon, :action, data, build_hash, keep_array)  
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
  
  def search_actions(args)
    action_info = Plugin::Action.search_actions(args)
    
    action_components = action_info[:components]
    action            = action_info[:actions]
      
    action_components.each do |component|
      args.shift
    end
    
    [ action, action_components, args ]
  end
  
  def action_help(action = nil, extended_help = false)
    Plugin::Action.action_help(action, extended_help)
  end
  
  #---
  
  def project(options, provider = nil)
    plugin(:nucleon, :project, provider, options)
  end
  
  def projects(data, build_hash = false, keep_array = false)
    plugins(:nucleon, :project, data, build_hash, keep_array)
  end
   
  #-----------------------------------------------------------------------------
  # Utility plugin type facade
  
  def command(options, provider = nil)
    plugin(:nucleon, :command, provider, options)
  end
  
  def commands(data, build_hash = false, keep_array = false)
    plugins(:nucleon, :command, data, build_hash, keep_array)
  end
   
  #---
  
  def event(options, provider = nil)
    plugin(:nucleon, :event, provider, options)
  end
  
  def events(data, build_hash = false, keep_array = false)
    plugins(:nucleon, :event, data, build_hash, keep_array)
  end
  
  #---
  
  def template(options, provider = nil)
    plugin(:nucleon, :template, provider, options)
  end
  
  def templates(data, build_hash = false, keep_array = false)
    plugins(:nucleon, :template, data, build_hash, keep_array)
  end
   
  #---
  
  def translator(options, provider = nil)
    plugin(:nucleon, :translator, provider, options)
  end
  
  def translators(data, build_hash = false, keep_array = false)
    plugins(:nucleon, :translator, data, build_hash, keep_array)
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
    logger.info("`#{name}` invoked: #{args.inspect}")

    $stdout.sync = true
    $stderr.sync = true
    
    exit_status = nil
    
    # We need to catch this early.
    Util::Console.use_colors = ! args.include?("--no-color")
    args = args - [ "--no-color", "--color" ]

    begin
      logger.debug("Beginning execution run")
      
      load_plugins
      
      arg_components = Util::CLI::Parser.split(args, cyan(name) + yellow(" <action components> [<arg> ...]"))
      main_command   = arg_components.shift
      
      action, action_components, args = search_actions(args)
      
      if main_command.processed && action.is_a?(Hash)
        exit_status = action_cli(action[:provider], args, false, name)
      else
        puts I18n.t('nucleon.core.exec.help.usage') + ': ' + main_command.help + "\n"
        puts I18n.t('nucleon.core.exec.help.header') + ":\n"
        
        action = main_command.processed ? action : nil
        puts action_help(action, args.include?("--help"))
        
        puts "\n" + I18n.t('nucleon.core.exec.help.footer', { :command => cyan(name) + yellow(" <action> -h") }) + "\n\n"   
        exit_status = code.help_wanted  
      end 
  
    rescue => error
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

