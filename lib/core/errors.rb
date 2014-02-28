
module Nucleon
module Errors
  
  #-----------------------------------------------------------------------------
  # Base error (based on VagrantError)
  
  class NucleonError < StandardError
    
    #---------------------------------------------------------------------------
    # Error constructor / destructor
    
    def initialize(*args)
      key     = args.shift if args.first.is_a?(Symbol)
      message = args.shift if args.first.is_a?(Hash)
      message ||= {}
      
      @extra_data = message.dup
      
      message[:key]       ||= error_key
      message[:namespace] ||= error_namespace
      message[:key]       = key if key

      if message[:key]
        message = translate_error(message)
      else
        message = error_message
      end

      super(message)
    end

    #---------------------------------------------------------------------------
    # Property accessor / modifiers
    
    attr_accessor :extra_data
    
    #---

    def self.error_key(key = nil, namespace = nil)
      define_method(:error_key) { key }
      error_namespace(namespace) if namespace
    end
    def error_key; nil; end # Default
    
    #---

    def self.error_message(message)
      define_method(:error_message) { message }
    end
    def error_message; "No error message"; end # Default
    
    #---

    def self.error_namespace(namespace)
      define_method(:error_namespace) { namespace }
    end
    def error_namespace; "nucleon.errors"; end # Default
    
    #---
    
    def self.status_code(code)
      define_method(:status_code) { code }
    end
    def status_code; 1; end # Default
    
    #---------------------------------------------------------------------------
    # Utilities

    def translate_error(options)
      return nil unless options[:key]
      I18n.t("#{options[:namespace]}.#{options[:key]}", options)
    end
    protected :translate_error
  end
  
  #-----------------------------------------------------------------------------
  # Specialized errors

  class BatchError < NucleonError
    error_key(:batch_error)
  end
  
  #---
  
  class SSHUnavailable < NucleonError
    error_key(:ssh_unavailable)
  end 
end
end