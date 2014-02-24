
module Nucleon
module Util
class Shell < Core
  
  include Celluloid
  
  #-----------------------------------------------------------------------------
  
  @@supervisors = {}
  
  #-----------------------------------------------------------------------------
  # Execution result interface
  
  class Result
    attr_accessor :status
    attr_reader :command
    
    def initialize(command)
      @command = command
      @output  = ''
      @errors  = ''
      @status  = Nucleon.code.success
    end
    
    #---
    
    def output
      @output.strip
    end
    
    def errors
      @errors.strip
    end
    
    #---
    
    def append_output(output_str)
      @output << output_str
    end
    
    def append_errors(error_str)
      @errors << error_str
    end  
  end
  
  #-----------------------------------------------------------------------------
  # Shell interface
  
  def self.connection(name = :core)
    name = name.to_sym
    init_shell(name) unless @@supervisors.has_key?(name)
    @@supervisors[name]
  end  
  
  def self.init_shell(name)
    name = name.to_sym
    
    Shell.supervise_as name
    @@supervisors[name] = Celluloid::Actor[name]  
  end
  
  #---
  
  execute_block_on_receiver :exec
    
  def exec(command, options = {}, &code)
    config = Config.ensure(options)
    
    min   = config.get(:min, 1).to_i
    tries = config.get(:tries, min).to_i
    tries = ( min > tries ? min : tries )
    
    info_prefix  = config.get(:info_prefix, '')
    info_suffix  = config.get(:info_suffix, '')
    error_prefix = config.get(:error_prefix, '')
    error_suffix = config.get(:error_suffix, '')
    
    ui           = config.get(:ui, Nucleon.ui)
    
    conditions   = Nucleon.events(config.get(:exit, {}), true)
    
    $stdout.sync = true
    $stderr.sync = true
    
    system_result = Result.new(command)
    
    for i in tries.downto(1)
      logger.info(">> running: #{command}")
      
      begin
        t1, output_new, output_orig, output_reader = pipe_exec_stream($stdout, conditions, { 
          :prefix => info_prefix, 
          :suffix => info_suffix, 
        }, 'output') do |data|
          system_result.append_output(data)
          code ? code.call(:output, command, data) : true
        end
        
        t2, error_new, error_orig, error_reader = pipe_exec_stream($stderr, conditions, { 
          :prefix => error_prefix, 
          :suffix => error_suffix, 
        }, 'error') do |data|
          system_result.append_errors(data)
          code ? code.call(:error, command, data) : true
        end
        
        system_success       = system(command)
        system_result.status = $?.exitstatus
        
      ensure
        output_success = close_exec_pipe(t1, $stdout, output_orig, output_new, 'output')
        error_success  = close_exec_pipe(t2, $stderr, error_orig, error_new, 'error')
      end
      
      success = ( system_success && output_success && error_success )
                  
      min -= 1
      break if success && min <= 0 && conditions.empty?
    end
    system_result
  end
  
  #---
  
  def pipe_exec_stream(output, conditions, options, label, &code)
    original     = output.dup
    read, write  = IO.pipe
    
    match_prefix = ( options[:match_prefix] ? options[:match_prefix] : 'EXIT' )
    
    thread = process_stream(read, original, options, label) do |data|
      check_conditions(data, conditions, match_prefix) do
        code ? code.call(data) : true
      end
    end
    
    thread.abort_on_exception = false
    
    output.reopen(write)    
    return thread, write, original, read
  end
  protected :pipe_exec_stream
  
  #---
  
  def close_exec_pipe(thread, output, original, write, label)
    output.reopen(original)
     
    write.close
    success = thread.value
    
    original.close
    return success
  end
  protected :close_exec_pipe
  
  #---
  
  def check_conditions(data, conditions, match_prefix = '', &code)
    prefix = ''
    
    unless ! conditions || conditions.empty?
      conditions.each do |key, event|
        if event.check(data)
          prefix = match_prefix
          conditions.delete(key)
        end
      end
    end
    
    result = true
    if code
      result = code.call
      
      unless prefix.empty?
        case result
        when Hash
          result[:prefix] = prefix
        else
          result = { :success => result, :prefix => prefix }
        end
      end
    end
    return result
  end
  protected :check_conditions
  
  #---
  
  def process_stream(input, output, options, label, &code)
    return Thread.new do
      success        = true      
      default_prefix = ( options[:prefix] ? options[:prefix] : '' )
      default_suffix = ( options[:suffix] ? options[:suffix] : '' )
      
      begin
        while ( data = input.readpartial(1024) )
          message = data.strip
          newline = ( data[-1,1].match(/\n/) ? true : false )
                                 
          unless message.empty?
            lines = message.split(/\n/)
            lines.each_with_index do |line, index|
              prefix  = default_prefix
              suffix  = default_suffix
              
              unless line.empty?
                if code
                  result = code.call(line)
                                          
                  if result && result.is_a?(Hash)
                    prefix = result[:prefix]
                    suffix = result[:suffix]
                    result = result[:success]                 
                  end
                  success = result if success
                end
            
                prefix = ( prefix && ! prefix.empty? ? prefix : '' )
                suffix = ( suffix && ! suffix.empty? ? suffix : '' )            
                eol    = ( index < lines.length - 1 || newline ? "\n" : ' ' )
            
                output.write(prefix.lstrip + line + suffix.rstrip + eol)
              end
            end
          end
        end
      rescue EOFError
      end
      
      input.close()
      success
    end
  end
  protected :process_stream
end
end
end
