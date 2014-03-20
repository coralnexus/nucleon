
module Nucleon
module Plugin
class Action < Base
  
  #-----------------------------------------------------------------------------
  # Default option interface
  
  class Option
    def initialize(namespace, provider, name, type, default, locale = nil, &validator)
      @provider  = provider
      @name      = name
      @type      = type
      @default   = default
      @locale    = locale.nil? ? "#{namespace}.actions.#{provider}.options.#{name}" : locale
      @validator = validator if validator
    end
    
    #---
    
    attr_reader :provider, :name, :type
    attr_accessor :default, :locale, :validator
    
    #---
    
    def validate(value, *args)
      success = true
      if @validator
        success = @validator.call(value, *args)
      end
      success
    end
  end

  #-----------------------------------------------------------------------------
  # Action plugin interface
  
  def self.exec_safe(provider, options)
    action_result = nil
    
    begin
      logger = Nucleon.logger
      
      logger.debug("Running nucleon action #{provider} with #{options.inspect}")
      action        = Nucleon.action(provider, options)
      exit_status   = action.execute
      action_result = action.result
      
    rescue Exception => error
      logger.error("Nucleon action #{provider} experienced an error:")
      logger.error(error.inspect)
      logger.error(error.message)
      logger.error(Nucleon::Util::Data.to_yaml(error.backtrace))

      Nucleon.ui.error(error.message, { :prefix => false }) if error.message
  
      exit_status = error.status_code if error.respond_to?(:status_code)
    end
    
    Nucleon.remove_plugin(action) if action

    exit_status = Nucleon.code.unknown_status unless exit_status.is_a?(Integer)
    { :status => exit_status, :result => action_result }  
  end
  
  def self.exec(provider, options, quiet = true)
    exec_safe(provider, { :settings => Config.ensure(options), :quiet => quiet })
  end
  
  def self.exec_cli(provider, args, quiet = false, name = :nucleon)
    results = exec_safe(provider, { :args => args, :quiet => quiet, :executable => name })
    results[:status]
  end
  
  #---
  
  def normalize(reload)
    args = array(delete(:args, []))
       
    @action_interface = Util::Liquid.new do |method, method_args|
      options = {}
      options = method_args[0] if method_args.length > 0
      
      quiet   = true
      quiet   = method_args[1] if method_args.length > 1
      
      myself.class.exec(method, options, quiet)
    end
    
    set(:config, Config.new)
        
    if get(:settings, nil)
      # Internal processing
      configure
      set(:processed, true)
      set(:settings, Config.ensure(get(:settings)))
      
      Nucleon.log_level = settings[:log_level] if settings.has_key?(:log_level)
    else
      # External processing
      set(:settings, Config.new)
      configure
      parse_base(args)
    end 
  end
  
  #-----------------------------------------------------------------------------
  # Checks
  
  def processed?
    get(:processed, false)
  end
  
  #-----------------------------------------------------------------------------
  # Property accessor / modifiers
  
  def namespace
    :nucleon
  end
  
  #---
   
  def config
    get(:config)
  end
  
  #---
  
  def config_subset(names)
    Util::Data.subset(config, names)
  end
  
  #---
   
  def settings
    get(:settings)
  end
  
  #---
  
  def register(name, type, default, locale = nil)
    name = name.to_sym
        
    if block_given?
      option = Option.new(namespace, plugin_provider, name, type, default, locale) do |value, success|
        yield(value, success)
      end
    else
      option = Option.new(namespace, plugin_provider, name, type, default, locale)
    end
    
    config[name]   = option
    settings[name] = option.default if settings[name].nil?
  end
  
  #---
  
  def remove(names)
    Util::Data.rm_keys(config, names)
    Util::Data.rm_keys(settings, names)
  end
  
  #---
  
  def ignore
    []
  end
    
  def options
    config.keys - arguments - ignore
  end
    
  def arguments
    []
  end
  
  #---
    
  def configure
    register :color, :bool, true, 'nucleon.core.action.options.color'
    
    yield if block_given?
    
    usage = "#{plugin_provider} "    
    arguments.each do |arg|
      arg_config = config[arg.to_sym]
      
      if arg_config.type == :array
        usage << "<#{arg}> ..."
      else
        usage << "<#{arg}> "  
      end      
    end
    myself.usage = usage
    myself
  end
  
  #---
  
  def usage=usage
    set(:usage, usage)
  end
  
  def usage
    get(:usage, '')
  end
  
  #---
  
  def help
    return @parser.help if @parser
    usage
  end
  
  #---
  
  def result=result
    set(:result, result)
  end
  
  def result
    get(:result, nil)
  end

  #-----------------------------------------------------------------------------
  # Operations
 
  def parse_base(args)    
    logger.info("Parsing action #{plugin_provider} with: #{args.inspect}")
    
    @parser = Util::CLI::Parser.new(args, usage) do |parser|
      parse(parser)      
      extension(:parse, { :parser => parser, :config => config })
    end
    
    if @parser 
      if @parser.processed
        set(:processed, true)
        settings.import(Util::Data.merge([ @parser.options, @parser.arguments ], true))
        logger.debug("Parse successful: #{export.inspect}")
        
      elsif @parser.options[:help] && ! quiet?
        executable = delete(:executable, '')
        puts I18n.t('nucleon.core.exec.help.usage') + ": #{executable} " + help + "\n"
        
      else
        if @parser.options[:help]
          logger.debug("Help wanted but running in silent mode")
        else
          logger.warn("Parse failed for unknown reasons")
        end
      end
    end
  end
  
  #---
  
  def parse(parser)
        
    generate = lambda do |format, name|
      formats = [ :option, :arg ]
      types   = [ :bool, :int, :float, :str, :array ]
      name    = name.to_sym
          
      if config.export.has_key?(name) && formats.include?(format.to_sym)
        option_config = config[name]
        type          = option_config.type
        default       = option_config.default
        locale        = option_config.locale        
        
        if types.include?(type.to_sym)
          value_label = "#{type.to_s.upcase}"
      
          if type == :bool
            parser.send("option_#{type}", name, default, "--[no-]#{name}", locale)        
          elsif format == :arg
            parser.send("#{format}_#{type}", name, default, locale)  
          else
            if type == :array
              parser.send("option_#{type}", name, default, "--#{name} #{value_label},...", locale)  
            else
              parser.send("option_#{type}", name, default, "--#{name} #{value_label}", locale)
            end
          end
        end           
      end
    end
     
    #---
    
    options.each do |name|
      generate.call(:option, name)  
    end
    
    arguments.each do |name|
      generate.call(:arg, name)
    end 
  end
  
  #---
  
  def validate(*args)
    # TODO: Add extension hooks and logging
    
    # Validate all of the configurations
    success = true
    config.export.each do |name, option|
      unless ignore.include?(name)
        success = false unless option.validate(settings[name], *args)
      end
    end
    if success
      # Check for missing arguments (in case of internal execution mode)
      arguments.each do |name| 
        if settings[name.to_sym].nil?
          warn('nucleon.core.exec.errors.missing_argument', { :name => name })
          success = false
        end
      end
    end
    success
  end
  
  #---
   
  def execute(skip_validate = false, skip_hooks = false)
    logger.info("Executing action #{plugin_provider}")
    
    myself.status = code.success
    myself.result = nil
    
    # TODO: Figure out how to deal with paralleization of actions with global ui settings
    use_colors = Util::Console.use_colors
    Util::Console.use_colors = @parser.options[:color]
    
    if processed?      
      begin
        if skip_validate || validate
          yield if block_given? && ( skip_hooks || extension_check(:exec_init) )
          myself.status = extension_set(:exec_exit) unless skip_hooks
        else
          puts "\n" + I18n.t('corl.core.exec.help.usage') + ': ' + help + "\n" unless quiet?
          myself.status = code.validation_failed 
        end
      ensure
        cleanup
      end
    else
      if @parser.options[:help]
        myself.status = code.help_wanted
      else
        myself.status = code.action_unprocessed
      end
    end
    
    myself.status = code.unknown_status unless status.is_a?(Integer)
    
    if processed? && status != code.success
      logger.warn("Execution failed for #{plugin_provider} with status #{status}: #{export.inspect}")
      alert(Codes.render_index(status))
    end  
    
    status
    
  ensure
    Util::Console.use_colors = use_colors 
  end
  
  #---
  
  def run
    @action_interface
  end
  
  #---
  
  def cleanup
    logger.info("Running cleanup for action #{plugin_provider}")
    
    yield if block_given?
    
    # Nothing to do right now
    extension(:cleanup)
  end
  
  #-----------------------------------------------------------------------------
  # Output
  
  def render_options
    settings
  end
end
end
end
