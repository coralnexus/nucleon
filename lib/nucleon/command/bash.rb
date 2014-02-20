
module Nucleon
module Command
class Bash < Plugin::Command

  #-----------------------------------------------------------------------------
  # Command plugin interface
  
  def normalize
    super
    myself.command = executable(myself)    
    logger.info("Setting command executable to #{command}")
  end
   
  #-----------------------------------------------------------------------------
  # Command operations
  
  def build(components = {}, overrides = nil, override_key = false)
    command            = string(components[:command])
    flags              = array( components.has_key?(:flags) ? components[:flags] : [] )
    data               = string_map(hash( components.has_key?(:data) ? components[:data] : {} ))
    args               = array( components.has_key?(:args) ? components[:args] : [] )
    subcommand         = hash( components.has_key?(:subcommand) ? components[:subcommand] : {} )
    
    override_key       = command unless override_key
    override_key       = override_key.to_sym
    
    command_string     = command.dup
    subcommand_string  = ''
    
    escape_characters  = /[\'\"]+/
    escape_replacement = '\"'
    
    dash_pattern       = /^([\-]+)/
    assignment_pattern = /\=$/
    
    logger.info("Building command #{command}")
    logger.debug("Command flags: #{flags.inspect}")
    logger.debug("Command options: #{data.inspect}")
    logger.debug("Command arguments: #{args.inspect}")
    logger.debug("Command has sub command") unless subcommand.empty?
    
    logger.debug("Overrides: #{overrides.inspect}")
    logger.debug("Override key: #{override_key}")
    
    # Flags
    if overrides && overrides.has_key?(:flags)
      if overrides[:flags].is_a?(Hash)
        if overrides[:flags].has_key?(override_key)
          flags = array(overrides[:flags][override_key])
        end
      else
        flags = array(overrides[:flags])
      end
    end
    flags.each do |flag|
      flag = string(flag)
      if ! flag.empty?        
        if flag.match(dash_pattern)
          dashes = $1
        else
          dashes = ( flag.size == 1 ? '-' : '--' )  
        end
        command_string << " #{dashes}#{flag}"
      end
    end
    
    # Data
    if overrides && overrides.has_key?(:data)
      if overrides[:data].has_key?(override_key)
        data = hash(overrides[:data][override_key])
      else
        override = true
        overrides[:data].each do |key, value|
          if ! value.is_a?(String)
            override = false
          end
        end
        data = hash(overrides[:data]) if override
      end
    end
    data.each do |key, value|
      key   = string(key)
      value = string(value).strip.sub(escape_characters, escape_replacement)
      
      if key.match(dash_pattern)
        dashes = $1
      else
        dashes = ( key.size == 1 ? '-' : '--' )  
      end      
      space = ( key.match(assignment_pattern) ? '' : ' ' )  
      
      command_string << " #{dashes}#{key}#{space}\"#{value}\""
    end
    
    # Arguments
    if overrides && overrides.has_key?(:args)
      unless overrides[:args].empty?
        if overrides[:args].is_a?(Hash)
          if overrides[:args].has_key?(override_key)
            args = array(overrides[:args][override_key])
          end
        else
          args = array(overrides[:args])
        end
      end
    end
    args.each do |arg|
      arg = string(arg).sub(escape_characters, escape_replacement)
      
      unless arg.empty?
        command_string << " \"#{arg}\""
      end
    end
    
    # Subcommand
    subcommand_overrides = ( overrides ? overrides[:subcommand] : nil )
    if subcommand && subcommand.is_a?(Hash) && ! subcommand.empty?
      subcommand_string = build(subcommand, subcommand_overrides)
    end
    
    command_string = (command_string + ' ' + subcommand_string).strip
    
    logger.debug("Rendered command: #{command_string}")
    return command_string
  end
  
  #---
    
  def exec(options = {}, overrides = nil, &code)
    config = Config.ensure(options)
    Nucleon.cli_run(build(export, overrides), config.import({ :ui => @ui }), &code)
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def executable(options)
    config = Config.ensure(options)
    
    return 'nucleon ' + config[:nucleon] if config.get(:nucleon, false)
    config[:command]
  end  
end
end
end
