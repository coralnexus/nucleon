
module Nucleon
module Plugin
class Action < Nucleon.plugin_class(:nucleon, :base)

  extend Mixin::Colors

  include Mixin::Action::Registration

  #-----------------------------------------------------------------------------
  # Info

  def self.describe(group = nil, action = 'unknown', weight = -1000, description = nil, help = nil)
    describe_base(group, action, weight, description, help)
  end

  def self.describe_base(group = nil, action = 'unknown', weight = -1000, description = nil, help = nil, provider_override = nil)
    if provider_override
      provider_override = provider_override.to_s.gsub('_', '.')
      description_id    = "#{namespace}.action.#{provider_override}.description"
      help_id           = "#{namespace}.action.#{provider_override}.help"
    else
      if group
        group_name     = Util::Data.array(group).join('.')
        description_id = "#{namespace}.action.#{group_name}.#{action}.description"
        help_id        = "#{namespace}.action.#{group_name}.#{action}.help"
      else
        description_id = "#{namespace}.action.#{action}.description"
        help_id        = "#{namespace}.action.#{action}.help"
      end
    end

    {
      :namespace   => namespace,
      :weight      => weight,
      :group       => group,
      :action      => action,
      :description => description ? description : I18n.t(description_id),
      :help        => help ? help : I18n.t(help_id)
    }
  end

  #---

  def self.namespace
    :nucleon
  end

  #-----------------------------------------------------------------------------
  # Default option interface

  class Option
    def initialize(namespace, provider, name, type, default, locale = nil, &validator)
      @provider  = provider
      @name      = name
      @type      = type
      @default   = default
      @locale    = locale.nil? ? "#{namespace}.action.#{provider.to_s.gsub('_', '.')}.options.#{name}" : locale
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

  def self.exec_safe(provider, options, handle_errors = true)
    action_result = nil

    begin
      logger = Nucleon.logger

      logger.debug("Running nucleon action #{provider} with #{options.inspect}")
      action        = Nucleon.action(provider, options)
      exit_status   = action.execute
      action_result = action.result

    rescue Interrupt
      raise
    rescue => error
      if handle_errors
        logger.error("Nucleon action #{provider} experienced an error:")
        logger.error(error.inspect)
        logger.error(error.message)
        logger.error(Nucleon::Util::Data.to_yaml(error.backtrace))

        Nucleon.ui.error(error.message, { :prefix => false }) if error.message

        exit_status = error.status_code if error.respond_to?(:status_code)
      else
        raise
      end
    end

    exit_status = Nucleon.code.unknown_status unless exit_status.is_a?(Integer)
    { :status => exit_status, :result => action_result }
  end

  def self.exec(provider, options, quiet = true, handle_errors = true)
    exec_safe(provider, { :settings => Config.ensure(options), :quiet => quiet }, handle_errors)
  end

  def self.exec_cli(provider, args, quiet = false, name = :nucleon, handle_errors = true)
    results = exec_safe(provider, { :args => args, :quiet => quiet, :executable => name }, handle_errors)
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

  def strict?
    true # Override in providers if needed (allow extra options if false)
  end

  #---

  def processed?
    get(:processed, false)
  end

  #-----------------------------------------------------------------------------
  # Property accessor / modifiers

  def index_config
    action_info = nil
    self.class.action_index(false).export.each do |action_id, info|
      if info[:provider] == plugin_provider
        action_info = info
        break
      end
    end
    Config.ensure(action_info)
  end

  #---

  def namespace
    self.class.namespace
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

  def register(name, type, default = nil, locale = nil, &code)
    name = name.to_sym

    if code
      option = Option.new(namespace, plugin_provider, name, type, default, locale) do |value, success|
        code.call(value, success)
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
    action_info = index_config

    yield(action_info) if block_given?

    group  = array(action_info[:description][:group])
    action = cyan(action_info[:description][:action])

    if ! group.empty?
      group = green(group.join(' ').strip)
      usage = "#{group} #{action} "
    else
      usage = "#{action} "
    end

    arguments.each do |arg|
      arg_config = config[arg.to_sym]

      arg_prefix = arg_config.default ? '[' : ''
      arg_suffix = arg_config.default ? ']' : ''

      if arg_config.type == :array
        usage << "#{arg_prefix}<#{arg}> ...#{arg_suffix}"
      else
        usage << "#{arg_prefix}<#{arg}>#{arg_suffix} "
      end
    end
    myself.usage = yellow(usage)
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

    action_info = index_config

    help_text = ''
    action_info[:description][:help].split("\n").each do |line|
      help_text << '     ' + green(line) + "\n"
    end

    @parser = Util::CLI::Parser.new(args, usage, "\n#{help_text}\n") do |parser|
      parser.strict = strict?

      parse(parser)
      extension(:parse, { :parser => parser, :config => config })
    end

    if @parser
      if @parser.processed
        set(:processed, true)
        settings.import(Util::Data.merge([ @parser.extra, @parser.options, @parser.arguments ], true))
        logger.debug("Parse successful")

      elsif @parser.options[:help] && ! quiet?
        executable = delete(:executable, '')
        puts I18n.t('nucleon.core.exec.help.usage') + ": " + executable.to_s + ' ' + help + "\n"

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

  def parse_types
    [ :bool, :int, :float, :str, :array ]
  end

  def parse(parser)

    generate = lambda do |format, name|
      formats = [ :option, :arg ]
      types   = parse_types
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

    if processed?
      begin
        if skip_validate || validate
          yield if block_given? && ( skip_hooks || extension_check(:exec_init) )
        else
          puts "\n" + I18n.t('nucleon.core.exec.help.usage') + ': ' + help + "\n" unless quiet?
          myself.status = code.validation_failed
          skip_hooks    = true
        end
      ensure
        finalize_execution(skip_hooks)
      end
    else
      if @parser.options[:help]
        myself.status = code.help_wanted
      else
        myself.status = code.action_unprocessed
      end
      finalize_execution(true)
    end
  end

  #---

  def finalize_execution(skip_hooks = false)
    begin
      myself.status = extension_set(:exec_exit, status) unless skip_hooks
    ensure
      cleanup
    end

    myself.status = code.unknown_status unless myself.status.is_a?(Integer)

    if processed? && myself.status != code.success
      logger.warn("Execution failed for #{plugin_provider} with status #{status}")
      warn(Codes.render_status(status), { :i18n => false })
    end
  end
  protected :finalize_execution

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
    options = super
    options.merge(settings.export)
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def self.components(search)
    components = []

    array(search).each do |element|
      break if element.match(/^\-+/)
      components << element
    end
    components
  end

  #---

  def self.action_index(tree = true)
    action_config = Config.new
    action_index  = Config.new

    generate_index = lambda do |info, parents = nil|
      groups = info.keys - [ :_weight, :_weights ]
      groups = groups.sort do |a, b|
        info[b][:_weight] <=> info[a][:_weight]
      end

      groups.each do |group|
        data = info[group]

        if data.is_a?(Hash) && data.has_key?(:_weights)
          sub_parents = parents.nil? ? [ group ] : [ parents, group ].flatten
          generate_index.call(data, sub_parents)
        else
          keys = tree ? [ parents, group ] : [ parents, group ].flatten.join('::')
          action_index.set(keys, data)
        end
      end
    end

    Nucleon.loaded_plugins(:nucleon, :action).each do |provider, data|
      description        = data[:class].describe
      data[:description] = description
      data[:_weight]     = description[:weight]

      keys = [ description[:namespace], description[:group], description[:action] ].flatten.compact
      action_config.set(keys, data)

      keys.pop

      while ! keys.empty?
        group_config = action_config.get(keys)

        if group_config.has_key?(:_weights)
          group_config[:_weights].push(description[:weight])
        else
          action_config.set([ keys, :_weights ], [ description[:weight] ])
        end
        action_config.set([ keys, :_weight ], group_config[:_weights].inject(0.0) { |sum, el| sum + el } / group_config[:_weights].size)
        keys.pop
      end
    end

    generate_index.call(action_config.export)
    action_index
  end

  #---

  def self.search_actions(search_components)
    action_components = components(search_components)
    action_index      = action_index(false).export
    actions_found     = []
    final_components  = []

    search_action = lambda do |components|
      unless components.empty?
        action_id         = components.is_a?(Array) ? components.flatten.join('::') : components
        action_id_pattern = action_id.gsub('::', ':.*:')

        action_index.each do |loaded_action_id, loaded_action_info|
          if loaded_action_id.match(/(^|\:)#{action_id_pattern.gsub(/\-/, '\-')}(\:|$)/)
            loaded_action_info[:action_id] = loaded_action_id
            actions_found << loaded_action_info
          end
        end
      end
      if components.is_a?(Array) && ! components.empty? && actions_found.empty?
        components.pop
        final_components = components
        search_action.call(components)
      else
        final_components = components
      end
    end

    search_action.call(action_components) unless action_components.empty?

    { :actions    => actions_found.size == 1 ? actions_found[0] : actions_found,
      :components => final_components
    }
  end

  #---

  def self.action_help(action = nil, extended_help = false)
    action_index      = action_index(false).export
    provider_index    = {}
    processed_actions = {}

    last_namespace    = nil
    last_group        = nil
    multiple_found    = false

    command_width           = 0
    namespace_command_width = {}

    output            = ''

    if action
      if action.empty?
        output << cyan(sprintf("\n%s\n", I18n.t('nucleon.core.exec.help.no_actions_found')))
      else
        multiple_found = true
        output << cyan(sprintf("\n%s\n", I18n.t('nucleon.core.exec.help.multiple_actions_found')))

        action.each do |info|
          provider_index[info[:provider]] = true
        end
      end
    end

    action_index.each do |action_id, info|
      if ! multiple_found || provider_index.has_key?(info[:provider])
        action        = Nucleon.action(info[:provider], { :settings => {}, :quiet => true })
        command_text  = action.help

        command_size  = command_text.gsub(/\e\[(\d+)m/, '').size
        command_width = [ command_width, command_size + 2 ].max

        namespace = info[:description][:namespace]

        namespace_command_width[namespace] = 0 unless namespace_command_width.has_key?(namespace)
        namespace_command_width[namespace] = [ namespace_command_width[namespace], command_size + 2 ].max

        if extended_help
          help_text = ''
          info[:description][:help].split("\n").each do |line|
            break if ! help_text.empty? && line.empty?
            help_text << '           ' + line + "\n"
          end
        else
          help_text = nil
        end

        processed_actions[action_id] = {
          :info    => info,
          :command => command_text,
          :help    => help_text
        }
      end
    end

    processed_actions.each do |action_id, info|
      command_text = info[:command]
      help_text    = info[:help]
      info         = info[:info]
      namespace    = info[:description][:namespace]
      group        = info[:description][:group]

      group_id = group.is_a?(Array) ? group.flatten.join('::') : group.to_s
      group_id = '' unless group_id

      output << "\n" if group_id != last_group

      if namespace != last_namespace
        output << "\n----------------------------------------------------\n" if help_text
        output << sprintf("\n   %s:\n\n", I18n.t('nucleon.core.exec.help.action_group', { :namespace => purple(namespace) }))
      end

      if help_text
        output << "       " + render_colorized(command_text, namespace_command_width[namespace]) + "  --  " + blue(info[:description][:description]) + "\n"
        output << "\n#{help_text}\n"
      else
        output << "       " + render_colorized(command_text, command_width) + "  --  " + blue(info[:description][:description]) + "\n"
      end

      last_namespace = namespace
      last_group     = group_id
    end
    output
  end

  #---

  def self.render_colorized(text, length = 0)
    command_size  = text.gsub(/\e\[(\d+)m/, '').size
    remaining     = [ length - command_size, 0 ].max
    text + sprintf("%#{remaining}s", ' ')
  end
end
end
end
